import Foundation

protocol MimeTypeCacheProtocol: Sendable {
    func getMimeType(fileUrl: URL) async -> String

    func setMimeType(md5: String, mimeType: String) async
}
