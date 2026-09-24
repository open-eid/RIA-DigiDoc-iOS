// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import UIKit
import SwiftUI
import UniformTypeIdentifiers
import FactoryKit
import UtilsLib

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
                if let error = error {
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
                                continuation.resume(throwing: FileImportError.dataConversionFailed)
                            }
                        }
                    } else if let itemUrl = item as? URL {
                        continuation.resume(returning: itemUrl)
                        return
                    } else {
                        continuation.resume(throwing: FileImportError.invalidItemData)
                        return
                    }
                } else {
                    continuation.resume(throwing: FileImportError.invalidItemData)
                    return
                }
            }
        }
    }

    private func extractSharedFileItems() async -> [ImportedFileItem] {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return []
        }

        let typeIdentifier = UTType.data

        var result: [ImportedFileItem] = []

        for item in inputItems {
            if let attachments = item.attachments {
                for provider in attachments where
                provider.hasItemConformingToTypeIdentifier(typeIdentifier.identifier) {
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
                        }
                    } catch let error {
                        ShareViewController.logger().error("Unable to load item: \(error.localizedDescription)")
                    }
                }
            }
        }

        return result
    }
}
