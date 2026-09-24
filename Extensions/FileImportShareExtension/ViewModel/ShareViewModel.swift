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

import Foundation
import UniformTypeIdentifiers
import FactoryKit
import CommonsLib
import UtilsLib
import Alamofire

@Observable
@MainActor
class ShareViewModel: ShareViewModelProtocol, Loggable {
    private let fileManager: FileManagerProtocol
    private let resourceChecker: URLResourceCheckerProtocol

    var status: Status = .processing

    public init(
        fileManager: FileManagerProtocol,
        resourceChecker: URLResourceCheckerProtocol
    ) {
        self.fileManager = fileManager
        self.resourceChecker = resourceChecker
    }

    @discardableResult
    func importFiles(_ items: [ImportedFileItem]) async -> Bool {
        guard !items.isEmpty else {
            await MainActor.run { [weak self] in
                self?.status = .failed
            }
            return false
        }
        do {
            let isImported = try await cacheItem(
                itemIndex: 0,
                providerIndex: 0,
                items: items
            )

            if isImported {
                ShareExtensionLogging.info("Imported \(items.count) shared file(s)")
            } else {
                ShareExtensionLogging.error("Unable to import all \(items.count) shared file(s)")
            }

            await MainActor.run { [weak self] in
                self?.status = isImported ? .imported : .failed
            }

            return isImported
        } catch {
            ShareExtensionLogging.error(
                "Unable to import shared files: \((error as NSError).domain) \((error as NSError).code)"
            )
            await MainActor.run { [weak self] in
                self?.status = .failed
            }
        }

        return false
    }

    func cacheItem(
        itemIndex: Int,
        providerIndex: Int,
        items: [ImportedFileItem]
    ) async throws -> Bool {
        guard itemIndex < items.count else {
            return true
        }

        let item = items[itemIndex]
        let imported = try await cacheFileForProvider(fileItem: item)
        if imported {
            return try await cacheItem(itemIndex: itemIndex + 1, providerIndex: providerIndex + 1, items: items)
        }

        return false
    }

    func cacheFileForProvider(fileItem: ImportedFileItem) async throws -> Bool {
        let typeIdentifiers = [UTType.fileURL, UTType.url, UTType.data]

        if typeIdentifiers.contains(fileItem.typeIdentifier) {
            return await cacheFileOnUrl(fileItem.fileUrl)
        }

        return false
    }

    func convertNSDataToURL(data: Data) throws -> URL {
        let tempDirectoryURL = fileManager.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appending(path: UUID().uuidString)

        try data.write(to: tempFileURL)
        return tempFileURL
    }

    func cacheFileOnUrl(
        _ itemUrl: URL,
    ) async -> Bool {
        if itemUrl.scheme == "file" {
            let accessing = itemUrl.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    itemUrl.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let isReachable = try resourceChecker.checkResourceIsReachable(itemUrl)
                guard isReachable else {
                    throw URLError(.cannotOpenFile)
                }

                let sourceSize = try fileSize(of: itemUrl)
                guard sourceSize > 0 else {
                    throw URLError(.zeroByteResource)
                }

                let groupTempFolderUrl = try Directories.getSharedFolder(fileManager: fileManager)
                let filePath = groupTempFolderUrl.appending(path: itemUrl.lastPathComponent)

                if fileManager.fileExists(atPath: filePath.resolvedPath) {
                    try fileManager.removeItem(at: filePath)
                }

                try fileManager.copyItem(at: itemUrl, to: filePath)

                let copiedSize = try fileSize(of: filePath)
                guard copiedSize == sourceSize else {
                    try? fileManager.removeItem(at: filePath)
                    throw URLError(.cannotWriteToFile)
                }

                return true
            } catch {
                let nsError = error as NSError
                ShareExtensionLogging.error(
                    "Unable to copy shared file: \(nsError.domain) \(nsError.code)"
                )
            }
        } else if itemUrl.isValidURL() {
            return await downloadFileFromUrl(itemUrl)
        } else {
            ShareExtensionLogging.error("Shared item has an unsupported scheme: \(itemUrl.scheme ?? "none")")
        }

        return false
    }

    private func fileSize(of url: URL) throws -> Int {
        let attributes = try fileManager.attributesOfItem(atPath: url.resolvedPath)
        guard let size = (attributes[.size] as? NSNumber)?.intValue else {
            throw URLError(.cannotOpenFile)
        }
        return size
    }

    func downloadFileFromUrl(_ itemUrl: URL) async -> Bool {
        ShareExtensionLogging.info("Downloading shared file")

        do {
            let destinationURL = try Directories.getTempDirectory(
                subfolder: Constants.Folder.Shared,
                fileManager: fileManager
            ).appending(path:
                itemUrl.lastPathComponent
            )

            let destination: DownloadRequest.Destination = { _, _ in
                return (destinationURL, [.createIntermediateDirectories, .removePreviousFile])
            }

            let request = AF.download(itemUrl, to: destination)

            let downloadTask = request.serializingDownloadedFileURL()

            let fileURL = try await downloadTask.value
            return await cacheFileOnUrl(fileURL)
        } catch let error {
            let nsError = error as NSError
            ShareExtensionLogging.error("Unable to download shared file: \(nsError.domain) \(nsError.code)")
            return false
        }
    }
}
