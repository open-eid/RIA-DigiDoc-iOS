import Foundation
import LibdigidocLibSwift

actor FileOpeningRepository: FileOpeningRepositoryProtocol {
    private let fileOpeningService: FileOpeningServiceProtocol

    init(fileOpeningService: FileOpeningServiceProtocol) {
        self.fileOpeningService = fileOpeningService
    }

    func isFileSizeValid(url: URL) async throws -> Bool {
        return try await fileOpeningService.isFileSizeValid(url: url)
    }

    func getValidFiles(_ result: Result<[URL], any Error>) async throws -> [URL] {
        return try await fileOpeningService.getValidFiles(result)
    }

    func openOrCreateContainer(urls: [URL]) async throws -> SignedContainer {
        return try await fileOpeningService.openOrCreateContainer(dataFiles: urls)
    }
}
