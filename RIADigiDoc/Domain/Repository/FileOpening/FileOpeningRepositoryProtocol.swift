import Foundation
import LibdigidocLibSwift

/// @mockable
public protocol FileOpeningRepositoryProtocol: Sendable {
    func isFileSizeValid(url: URL) async throws -> Bool
    func getValidFiles(_ result: Result<[URL], Error>) async throws -> [URL]
    func openOrCreateContainer(urls: [URL], isSivaConfirmed: Bool) async throws -> SignedContainerProtocol
    func isSivaConfirmationNeeded(files: [URL]) async -> Bool
}
