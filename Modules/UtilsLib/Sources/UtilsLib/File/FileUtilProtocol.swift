import Foundation

public protocol FileUtilProtocol: Sendable {
    func getMimeTypeFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String
    ) async throws -> String?

    func getValidFileInApp(currentURL: URL) throws -> URL?

    func isFileFromAppGroup(url: URL, appGroupURL: URL?) throws -> Bool

    func isFileFromiCloud(fileURL: URL) -> Bool

    func isFileDownloadedFromiCloud(fileURL: URL) -> Bool

    func downloadFileFromiCloud(fileURL: URL, completion: @escaping @Sendable (URL?) -> Void)

    func getAllFileURLs(from folderURL: URL) -> [URL]

    func removeSharedFiles(url: URL?) throws
}
