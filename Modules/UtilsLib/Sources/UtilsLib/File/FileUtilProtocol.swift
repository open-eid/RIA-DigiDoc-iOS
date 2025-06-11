import Foundation
import CommonsLib

/// @mockable
public protocol FileUtilProtocol: Sendable {
    func getMimeTypeFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String,
        fileManager: FileManagerProtocol
    ) async throws -> String?

    func getValidFileInApp(
        currentURL: URL,
        fileManager: FileManagerProtocol
    ) throws -> URL?

    func isFileFromAppGroup(url: URL, appGroupURL: URL?) throws -> Bool

    func isFileFromiCloud(fileURL: URL) -> Bool

    func isFileDownloadedFromiCloud(fileURL: URL) -> Bool

    func downloadFileFromiCloud(
        fileURL: URL,
        fileManager: FileManagerProtocol,
        completion: @escaping @Sendable (URL?) -> Void
    )

    func getAllFileURLs(
        from folderURL: URL,
        fileManager: FileManagerProtocol
    ) -> [URL]

    func removeSharedFiles(
        url: URL?,
        fileManager: FileManagerProtocol
    ) throws
}

extension FileUtilProtocol {
    public func getMimeTypeFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String,
        fileManager: FileManagerProtocol = FileManager.default
    ) async throws -> String? {
        return try await getMimeTypeFromZipFile(
            from: zipFileURL,
            fileNameToFind: fileNameToFind,
            fileManager: fileManager
        )
    }

    public func getValidFileInApp(
        currentURL: URL,
        fileManager: FileManagerProtocol = FileManager.default
    ) throws -> URL? {
        return try getValidFileInApp(
            currentURL: currentURL,
            fileManager: fileManager
        )
    }

    public func downloadFileFromiCloud(
        fileURL: URL,
        fileManager: FileManagerProtocol = FileManager.default,
        completion: @escaping @Sendable (URL?) -> Void
    ) {
        return downloadFileFromiCloud(
            fileURL: fileURL,
            fileManager: fileManager,
            completion: completion
        )
    }

    public func getAllFileURLs(
        from folderURL: URL,
        fileManager: FileManagerProtocol = FileManager.default
    ) -> [URL] {
        return getAllFileURLs(
            from: folderURL,
            fileManager: fileManager
        )
    }

    public func removeSharedFiles(
        url: URL?,
        fileManager: FileManagerProtocol = FileManager.default
    ) throws {
        return try removeSharedFiles(
            url: url,
            fileManager: fileManager
        )
    }
}
