import Foundation

protocol MimeTypeResolverProtocol: Sendable {
    func mimeType(url: URL) async -> String
}
