import Foundation

public protocol SignedContainerProtocol: Sendable {
    static func openOrCreate(file: URL, dataFiles: [URL?]?) async throws -> SignedContainer
}
