import Foundation

/// @mockable
public protocol MimeTypeResolverProtocol: Sendable {
    func mimeType(url: URL) async -> String
}
