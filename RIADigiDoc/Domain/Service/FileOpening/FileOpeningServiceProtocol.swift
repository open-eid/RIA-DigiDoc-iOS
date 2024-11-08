import Foundation
import LibdigidoclibSwift

protocol FileOpeningServiceProtocol: Sendable {
    func isFileSizeValid(url: URL) async throws -> Bool
    func getValidFiles(_ result: Result<[URL], Error>) async throws -> [URL]
    func openOrCreateContainer(dataFiles: [URL]) async throws -> SignedContainer
}
