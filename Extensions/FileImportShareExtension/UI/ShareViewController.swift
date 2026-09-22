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
    func loadItem(for provider: NSItemProvider, typeIdentifier: String, diagIndex: Int = -1) async throws -> URL {
        let diagStart = ContinuousClock.now
        ShareExtensionLogging.emit("phase=loadItem.request idx=\(diagIndex) type=\(typeIdentifier)")

        return try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, error in
                let diagLog = Logger(subsystem: "ee.ria.digidoc.shareext.logging", category: "import")
                let diagComponents = diagStart.duration(to: .now).components
                let diagElapsedMs = diagComponents.seconds * 1000
                    + diagComponents.attoseconds / 1_000_000_000_000_000
                let diagError = error as NSError?
                let diagItemClass = item.map { String(describing: type(of: $0)) } ?? "nil"
                diagLog.info(
                    """
                    phase=loadItem.callback idx=\(diagIndex, privacy: .public) \
                    elapsedMs=\(diagElapsedMs, privacy: .public) \
                    itemClass=\(diagItemClass, privacy: .public) \
                    hasError=\(error != nil, privacy: .public) \
                    errDomain=\(diagError?.domain ?? "none", privacy: .public) \
                    errCode=\(diagError?.code ?? 0, privacy: .public)
                    """
                )

                if let error = error {
                    continuation
                        .resume(
                            throwing: FileImportError.loadError(description: error.localizedDescription)
                        )
                } else if item != nil {
                    if let itemData = item as? Data {
                        diagLog.info(
                            """
                            phase=loadItem.data idx=\(diagIndex, privacy: .public) \
                            bytes=\(itemData.count, privacy: .public)
                            """
                        )
                        Task {
                            do {
                                let url = try await self.viewModel.convertNSDataToURL(data: itemData)
                                continuation.resume(returning: url)
                            } catch {
                                diagLog.error(
                                    """
                                    phase=loadItem.dataConvertFailed \
                                    idx=\(diagIndex, privacy: .public) bytes=\(itemData.count, privacy: .public)
                                    """
                                )
                                continuation.resume(throwing: FileImportError.dataConversionFailed)
                            }
                        }
                    } else if let itemUrl = item as? URL {
                        continuation.resume(returning: itemUrl)
                        return
                    } else {
                        diagLog.error(
                            """
                            phase=loadItem.rejected idx=\(diagIndex, privacy: .public) \
                            reason=unsupportedClass itemClass=\(diagItemClass, privacy: .public)
                            """
                        )
                        continuation.resume(throwing: FileImportError.invalidItemData)
                        return
                    }
                } else {
                    diagLog.error(
                        """
                        phase=loadItem.rejected idx=\(diagIndex, privacy: .public) reason=nilItem
                        """
                    )
                    continuation.resume(throwing: FileImportError.invalidItemData)
                    return
                }
            }
        }
    }

    private func extractSharedFileItems() async -> [ImportedFileItem] {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            ShareExtensionLogging.emit("phase=extract.noInputItems hasContext=\(extensionContext != nil)")
            return []
        }

        let typeIdentifier = UTType.data

        var result: [ImportedFileItem] = []

        var diagIndex = -1
        let diagTotalProviders = inputItems.reduce(0) { $0 + ($1.attachments?.count ?? 0) }
        ShareExtensionLogging.emit(
            "phase=extract.begin items=\(inputItems.count) providers=\(diagTotalProviders) "
                + "memMB=\(ShareExtensionLogging.availableMemoryMB)"
        )

        for item in inputItems {
            if let attachments = item.attachments {
                for provider in attachments {
                    diagIndex += 1
                    let diagConforms = provider.hasItemConformingToTypeIdentifier(typeIdentifier.identifier)
                    let suggestedAttributes = provider.suggestedName
                        .map(ShareExtensionLogging.nameAttributes) ?? "absent"
                    ShareExtensionLogging.emit(
                        "phase=provider.begin idx=\(diagIndex) conforms=\(diagConforms) "
                            + "types=\(provider.registeredTypeIdentifiers.joined(separator: "|")) "
                            + "hasSuggestedName=\(provider.suggestedName != nil) "
                            + "suggested=[\(suggestedAttributes)] "
                            + "memMB=\(ShareExtensionLogging.availableMemoryMB)"
                    )

                    guard diagConforms else { continue }

                    do {
                        let url = try await loadItem(
                            for: provider,
                            typeIdentifier: typeIdentifier.identifier,
                            diagIndex: diagIndex
                        )
                        ShareExtensionLogging.emit(
                            "phase=provider.loaded idx=\(diagIndex) "
                                + "url=[\(ShareExtensionLogging.nameAttributes(url.lastPathComponent))] "
                                + "srcSize=\(ShareExtensionLogging.fileSize(of: url)) "
                                + "memMB=\(ShareExtensionLogging.availableMemoryMB)"
                        )

                        if let fileData = try? Data(contentsOf: url) {
                            ShareExtensionLogging.emit(
                                "phase=provider.readData idx=\(diagIndex) bytes=\(fileData.count) "
                                    + "memMB=\(ShareExtensionLogging.availableMemoryMB)"
                            )
                            result.append(ImportedFileItem(
                                fileUrl: url,
                                filename: url.lastPathComponent,
                                data: fileData,
                                typeIdentifier: typeIdentifier
                            ))
                        } else {
                            ShareExtensionLogging.emit("phase=provider.readDataFailed idx=\(diagIndex)")
                        }
                    } catch let error {
                        let diagReason: String
                        switch error {
                        case FileImportError.loadError: diagReason = "loadError"
                        case FileImportError.dataConversionFailed: diagReason = "dataConversionFailed"
                        case FileImportError.invalidItemData: diagReason = "invalidItemData"
                        default: diagReason = "\((error as NSError).domain):\((error as NSError).code)"
                        }
                        ShareExtensionLogging.emit("phase=provider.failed idx=\(diagIndex) reason=\(diagReason)")
                        ShareViewController.logger().error("Unable to load item: \(error.localizedDescription)")
                    }
                }
            }
        }

        ShareExtensionLogging.emit(
            "phase=extract.end produced=\(result.count) of=\(diagTotalProviders) "
                + "memMB=\(ShareExtensionLogging.availableMemoryMB)"
        )

        return result
    }
}
