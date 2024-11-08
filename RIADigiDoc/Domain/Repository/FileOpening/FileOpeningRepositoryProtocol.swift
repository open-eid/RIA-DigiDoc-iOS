import Foundation
import LibdigidoclibSwift

protocol FileOpeningRepositoryProtocol: Sendable {
    func isFileSizeValid(url: URL) async throws -> Bool
    func getValidFiles(_ result: Result<[URL], Error>) async throws -> [URL]
    func openOrCreateContainer(urls: [URL]) async throws -> SignedContainer
}
