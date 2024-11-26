import Foundation

public protocol FileUtilProtocol: Sendable {
    func getMimeTypeFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String
    ) throws -> String?
}
