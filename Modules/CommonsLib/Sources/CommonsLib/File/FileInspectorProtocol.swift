import Foundation

/// @mockable
public protocol FileInspectorProtocol: Sendable {
    func fileSize(for url: URL) throws -> Int
}
