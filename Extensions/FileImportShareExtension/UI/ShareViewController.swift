/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import CommonsLib
import UIKit
import SwiftUI
import UniformTypeIdentifiers
import FactoryKit
import UtilsLib
import os

class ShareViewController: UIViewController, Sendable, Loggable {
    let viewModel = Container.shared.shareViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.status = .processing

        let shareView = ShareView(
            statusChanged: { [weak self] in
                guard let self else { return }

                Task {
                    let sharedItems = await self.extractSharedFileItems()
                    await self.viewModel.importFiles(sharedItems)
                }
            },
            completeRequest: { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        )

        let hostingController = UIHostingController(rootView: shareView)
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
    }

    @MainActor
    func loadItem(for provider: NSItemProvider, typeIdentifier: String) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, error in
                let log = Logger(subsystem: "ee.ria.digidoc.shareext.logging", category: "import")

                if let error = error {
                    let nsError = error as NSError
                    log.error(
                        """
                        Unable to load shared item: \(nsError.domain, privacy: .public) \
                        \(nsError.code, privacy: .public)
                        """
                    )
                    continuation
                        .resume(
                            throwing: FileImportError.loadError(description: error.localizedDescription)
                        )
                } else if item != nil {
                    if let itemData = item as? Data {
                        Task {
                            do {
                                let url = try await self.viewModel.convertNSDataToURL(data: itemData)
                                continuation.resume(returning: url)
                            } catch {
                                log.error("Unable to write shared item data to a temporary file")
                                continuation.resume(throwing: FileImportError.dataConversionFailed)
                            }
                        }
                    } else if let itemUrl = item as? URL {
                        continuation.resume(returning: itemUrl)
                        return
                    } else {
                        log.error(
                            """
                            Shared item is not a file or data: \
                            \(String(describing: type(of: item!)), privacy: .public)
                            """
                        )
                        continuation.resume(throwing: FileImportError.invalidItemData)
                        return
                    }
                } else {
                    log.error("Shared item is empty")
                    continuation.resume(throwing: FileImportError.invalidItemData)
                    return
                }
            }
        }
    }

    private func extractSharedFileItems() async -> [ImportedFileItem] {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            ShareExtensionLogging.error("Share extension received no input items")
            return []
        }

        let typeIdentifier = UTType.data

        var result: [ImportedFileItem] = []
        let totalProviders = inputItems.reduce(0) { $0 + ($1.attachments?.count ?? 0) }

        ShareExtensionLogging.info("Importing \(totalProviders) shared item(s)")

        for item in inputItems {
            if let attachments = item.attachments {
                for provider in attachments {
                    guard provider.hasItemConformingToTypeIdentifier(typeIdentifier.identifier) else {
                        ShareExtensionLogging.error(
                            """
                            Skipping shared item of unsupported type: \
                            \(provider.registeredTypeIdentifiers.joined(separator: ","))
                            """
                        )
                        continue
                    }

                    do {
                        let url = try await loadItem(
                            for: provider,
                            typeIdentifier: typeIdentifier.identifier
                        )

                        if let fileData = try? Data(contentsOf: url) {
                            result.append(ImportedFileItem(
                                fileUrl: url,
                                filename: url.lastPathComponent,
                                data: fileData,
                                typeIdentifier: typeIdentifier
                            ))
                        } else {
                            ShareExtensionLogging.error("Unable to read the loaded shared item")
                        }
                    } catch let error {
                        ShareExtensionLogging.error(
                            "Unable to load shared item: \(String(describing: type(of: error)))"
                        )
                    }
                }
            }
        }

        if result.count != totalProviders {
            ShareExtensionLogging.error("Prepared \(result.count) of \(totalProviders) shared item(s)")
        }

        return result
    }
}
