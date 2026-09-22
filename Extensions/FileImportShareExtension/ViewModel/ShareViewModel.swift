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
        ShareViewModel.logger().info("Importing files...")
        ShareExtensionLogging.emit(
            "phase=import.begin count=\(items.count) memMB=\(ShareExtensionLogging.availableMemoryMB)"
        )
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

            ShareExtensionLogging.emit(
                "phase=import.end ok=\(isImported) memMB=\(ShareExtensionLogging.availableMemoryMB)"
            )

            if isImported {
                ShareViewModel.logger().info("Files imported successfully")
            } else {
                ShareViewModel.logger().error("Could not import files")
            }

            await MainActor.run { [weak self] in
                self?.status = isImported ? .imported : .failed
            }

            return isImported
        } catch {
            ShareViewModel.logger().error("Unable to import files: \(error.localizedDescription)")
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
        ShareExtensionLogging.emit("phase=item.result idx=\(itemIndex) of=\(items.count) ok=\(imported)")
        if imported {
            return try await cacheItem(itemIndex: itemIndex + 1, providerIndex: providerIndex + 1, items: items)
        }

        return false
    }

    func cacheFileForProvider(fileItem: ImportedFileItem) async throws -> Bool {
        let typeIdentifiers = [UTType.fileURL, UTType.url, UTType.data]

        ShareExtensionLogging.emit(
            "phase=cache.dispatch typeId=\(fileItem.typeIdentifier.identifier) "
                + "matched=\(typeIdentifiers.contains(fileItem.typeIdentifier)) "
                + "scheme=\(fileItem.fileUrl.scheme ?? "nil")"
        )

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
                ShareExtensionLogging.emit(
                    "phase=cache.reachable ok=\(isReachable) "
                        + "readable=\(fileManager.isReadableFile(atPath: itemUrl.resolvedPath)) "
                        + "src=[\(ShareExtensionLogging.nameAttributes(itemUrl.lastPathComponent))]"
                )

                guard isReachable else {
                    throw URLError(.cannotOpenFile)
                }

                let sourceSize = try fileSize(of: itemUrl)
                guard sourceSize > 0 else {
                    throw URLError(.zeroByteResource)
                }

                let groupTempFolderUrl = try Directories.getSharedFolder(fileManager: fileManager)
                let filePath = groupTempFolderUrl.appending(path: itemUrl.lastPathComponent)

                ShareExtensionLogging.emit(
                    "phase=cache.dest dest=[\(ShareExtensionLogging.nameAttributes(filePath.lastPathComponent))] "
                        + "destExists=\(fileManager.fileExists(atPath: filePath.resolvedPath))"
                )

                if fileManager.fileExists(atPath: filePath.resolvedPath) {
                    try fileManager.removeItem(at: filePath)
                }

                try fileManager.copyItem(at: itemUrl, to: filePath)

                let copiedSize = try fileSize(of: filePath)
                guard copiedSize == sourceSize else {
                    try? fileManager.removeItem(at: filePath)
                    throw URLError(.cannotWriteToFile)
                }

                ShareExtensionLogging.emit("phase=cache.done srcSize=\(sourceSize) destSize=\(copiedSize)")

                return true
            } catch {
                let nsError = error as NSError
                ShareExtensionLogging.emit(
                    "phase=cache.error errDomain=\(nsError.domain) errCode=\(nsError.code) "
                        + "userInfoKeys=\(nsError.userInfo.keys.sorted().joined(separator: ","))"
                )
                ShareViewModel.logger().error("Unable to cache file: \(error.localizedDescription)")
            }
        } else if itemUrl.isValidURL() {
            return await downloadFileFromUrl(itemUrl)
        }

        ShareExtensionLogging.emit("phase=cache.returningFalse scheme=\(itemUrl.scheme ?? "nil")")

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
        ShareViewModel.logger().info("Downloading file from \(itemUrl.absoluteString)")

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

            Task {
                for await progress in request.downloadProgress() {
                    let fileName = itemUrl.lastPathComponent
                    let downloadProgress = progress.fractionCompleted * 100
                    ShareViewModel.logger().info(
                        "\(String(format: "Download progress for file '%@': %.2f%%", fileName, downloadProgress))"
                    )
                }
            }

            let downloadTask = request.serializingDownloadedFileURL()

            let fileURL = try await downloadTask.value
            return await cacheFileOnUrl(fileURL)
        } catch let error {
            let errorDescription = error.localizedDescription
            ShareViewModel.logger().error(
                "\(String(format: "Unable to download file %@: %@", itemUrl.absoluteString, errorDescription))"
            )
            return false
        }
    }
}
