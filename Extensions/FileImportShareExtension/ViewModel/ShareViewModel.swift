import Foundation
import OSLog
import UniformTypeIdentifiers
import CommonsLib
import UtilsLib
import Alamofire

@MainActor
class ShareViewModel: NSObject, ShareViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.FileImportShareExtension",
        category: "ShareViewController"
    )

    @Published var status: Status = .processing

    private let fileManager: FileManagerProtocol
    private let resourceChecker: URLResourceCheckerProtocol

    public init(
        fileManager: FileManagerProtocol = FileManager.default,
        resourceChecker: URLResourceCheckerProtocol = URLResourceChecker()
    ) {
        self.fileManager = fileManager
        self.resourceChecker = resourceChecker
    }

    @discardableResult
    func importFiles(_ items: [ImportedFileItem]) async -> Bool {
        ShareViewModel.logger.debug("Importing files...")
        guard !items.isEmpty else {
            status = .failed
            return false
        }
        do {
            let isImported = try await cacheItem(
                itemIndex: 0,
                providerIndex: 0,
                items: items
            )

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
        let tempFileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString)

        try data.write(to: tempFileURL)
        return tempFileURL
    }

    func cacheFileOnUrl(
        _ itemUrl: URL,
    ) async -> Bool {
        if itemUrl.scheme == "file" {
            do {
                if try !resourceChecker.checkResourceIsReachable(itemUrl) {
                    throw URLError(.cannotOpenFile)
                }

                let groupTempFolderUrl = try Directories.getSharedFolder(fileManager: fileManager)

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
                subfolder: Constants.Folder.Shared,
                fileManager: fileManager
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
