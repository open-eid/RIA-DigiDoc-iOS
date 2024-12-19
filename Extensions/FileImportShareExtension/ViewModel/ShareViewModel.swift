import Foundation
import OSLog
import UniformTypeIdentifiers
import CommonsLib
import UtilsLib
import Alamofire

@MainActor
class ShareViewModel: NSObject, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.FileImportShareExtension",
        category: "ShareViewController"
    )

    @Published var status: Status = .processing

    @discardableResult
    func importFiles(extensionContext: NSExtensionContext?) async -> Bool {
        ShareViewModel.logger.debug("Importing files...")
        guard let items = extensionContext?.inputItems as? [NSExtensionItem], !items.isEmpty else {
            status = .failed
            return false
        }
        do {
            let isImported = try await cacheItem(itemIndex: 0, providerIndex: 0, items: items)
            if isImported {
                ShareViewModel.logger.debug("Files imported successfully")
            } else {
                ShareViewModel.logger.error("Could not import files")
            }

            status = isImported ? .imported : .failed

            return isImported
        } catch {
            ShareViewModel.logger.error("Unable to import files: \(error.localizedDescription)")
            status = .failed
        }

        return false
    }

    func cacheItem(itemIndex: Int, providerIndex: Int, items: [NSExtensionItem]) async throws -> Bool {
        guard itemIndex < items.count else {
            return true
        }

        let item = items[itemIndex]
        guard let attachments = item.attachments, providerIndex < attachments.count else {
            return try await cacheItem(itemIndex: itemIndex + 1, providerIndex: 0, items: items)
        }

        let provider = attachments[providerIndex]
        let imported = try await cacheFileForProvider(provider: provider)
        if imported {
            return try await cacheItem(itemIndex: itemIndex, providerIndex: providerIndex + 1, items: items)
        }

        return false
    }

    func cacheFileForProvider(provider: NSItemProvider?) async throws -> Bool {
        guard let provider = provider else { return false }

        let typeIdentifiers = [UTType.fileURL.identifier, UTType.url.identifier, UTType.data.identifier]

        for typeIdentifier in typeIdentifiers where provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
            let item = try await loadItem(for: provider, typeIdentifier: typeIdentifier)
            return await cacheFileOnUrl(item)
        }

        return false
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
                                let dataToUrl = try await self.convertNSDataToURL(data: itemData)
                                continuation.resume(returning: dataToUrl)
                                return
                            } catch {
                                continuation.resume(throwing: FileImportError.dataConversionFailed)
                                return
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

    func convertNSDataToURL(data: Data) throws -> URL {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString)

        try data.write(to: tempFileURL)
        return tempFileURL
    }

    func cacheFileOnUrl(_ itemUrl: URL) async -> Bool {
        if itemUrl.scheme == "file" {
            do {
                if try !itemUrl.checkResourceIsReachable() {
                    throw URLError(.cannotOpenFile)
                }

                let groupTempFolderUrl = try Directories.getSharedFolder()

                let filePath = groupTempFolderUrl.appendingPathComponent(itemUrl.lastPathComponent)

                let inputStream = InputStream(url: itemUrl)
                let outputStream = OutputStream(url: filePath, append: false)

                inputStream?.open()
                outputStream?.open()

                let bufferSize = 4096
                var dataBuffer = Data(count: bufferSize)

                while inputStream?.hasBytesAvailable == true {
                    let bytesRead: Int? = dataBuffer
                        .withUnsafeMutableBytes { (rawBufferPointer: UnsafeMutableRawBufferPointer) in
                            guard let inputStream = inputStream else {
                                return nil
                            }

                            return rawBufferPointer
                                .bindMemory(to: UInt8.self)
                                .baseAddress
                                .map { baseAddress in
                                    inputStream.read(baseAddress, maxLength: bufferSize)
                                }
                        }

                    if let bytesRead = bytesRead, bytesRead > 0 {
                        dataBuffer.count = bytesRead
                        dataBuffer.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) in
                            guard let outputStream = outputStream,
                                  let baseAddress = bufferPointer.bindMemory(to: UInt8.self).baseAddress else {
                                return
                            }

                            outputStream.write(baseAddress, maxLength: bytesRead)
                        }
                    }
                }

                inputStream?.close()
                outputStream?.close()

                return true
            } catch {
                ShareViewModel.logger.error("Unable to cache file: \(error.localizedDescription)")
            }
        } else if itemUrl.isValidURL() {
            return await downloadFileFromUrl(itemUrl)
        }

        return false
    }

    func downloadFileFromUrl(_ itemUrl: URL) async -> Bool {
        ShareViewModel.logger.debug("Downloading file from \(itemUrl.absoluteString)")

        do {
            let destinationURL = try Directories.getTempDirectory(
                subfolder: Constants.Folder.Shared
            ).appendingPathComponent(
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
                    ShareViewModel.logger.debug(
                        "\(String(format: "Download progress for file '%@': %.2f%%", fileName, downloadProgress))"
                    )
                }
            }

            let downloadTask = request.serializingDownloadedFileURL()

            let fileURL = try await downloadTask.value
            return await cacheFileOnUrl(fileURL)
        } catch let error {
            let errorDescription = error.localizedDescription
            ShareViewModel.logger.error(
                "\(String(format: "Unable to download file %@: %@", itemUrl.absoluteString, errorDescription))"
            )
            return false
        }
    }
}
