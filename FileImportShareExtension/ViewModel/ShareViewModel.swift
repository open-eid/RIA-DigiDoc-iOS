import Foundation
import OSLog
import UniformTypeIdentifiers
import CommonsLib
import UtilsLib

@MainActor
class ShareViewModel: ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.FileImportShareExtension",
        category: "ShareViewController"
    )

    @Published var status: Status = .processing

    @discardableResult
    func importFiles(extensionContext: NSExtensionContext?) async -> Bool {
        ShareViewModel.logger.debug("Importing files...")
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return false }
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
                } else {
                    if let item = item {
                        if let itemData = item as? Data {
                            DispatchQueue.main.async {
                                do {
                                    let convertedDataToUrl = try self.convertNSDataToURL(data: itemData)
                                    guard let dataToUrl = convertedDataToUrl else { continuation.resume(
                                        throwing: FileImportError.dataConversionFailed
                                    )
                                        return
                                    }
                                    continuation.resume(returning: dataToUrl)
                                    return
                                } catch {
                                    continuation.resume(throwing: FileImportError.dataConversionFailed)
                                    return
                                }
                            }
                        }
                        if let itemUrl = item as? NSURL {
                            continuation.resume(returning: itemUrl as URL)
                            return
                        }
                    }
                    continuation.resume(throwing: FileImportError.invalidItemData)
                }
            }
        }
    }

    func convertNSDataToURL(data: Data) throws -> URL? {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString)

        try data.write(to: tempFileURL)
        return tempFileURL
    }

    func cacheFileOnUrl(_ itemUrl: URL) async -> Bool {
        if itemUrl.scheme == "file" {
            do {
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
        } else {
            return await downloadFileFromUrl(itemUrl)
        }
        return false
    }

    func downloadFileFromUrl(_ itemUrl: URL) async -> Bool {
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: Constants.Identifier.GroupDownload)
        sessionConfig.sharedContainerIdentifier = Constants.Identifier.Group

        ShareViewModel.logger.debug("Downloading file from \(itemUrl.path)")

        let session = URLSession(configuration: sessionConfig)
        do {
            let (location, _) = try await session.download(from: itemUrl)

            return await cacheFileOnUrl(location)
        } catch {
            ShareViewModel.logger.error("Unable to download file: \(error.localizedDescription)")
            return false
        }
    }
}
