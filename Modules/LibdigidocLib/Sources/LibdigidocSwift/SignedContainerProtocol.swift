import Foundation

public protocol SignedContainerProtocol: Sendable {
    static func openOrCreate(dataFiles: [URL]) async throws -> SignedContainer
}
