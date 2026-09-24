// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoSwift
import LibdigidocLibSwift

actor FileOpeningRepository: FileOpeningRepositoryProtocol {
    private let fileOpeningService: FileOpeningServiceProtocol
    private let sivaService: SivaServiceProtocol

    init(fileOpeningService: FileOpeningServiceProtocol, sivaService: SivaServiceProtocol) {
        self.fileOpeningService = fileOpeningService
        self.sivaService = sivaService
    }

    func isFileSizeValid(url: URL) async throws -> Bool {
        return try await fileOpeningService.isFileSizeValid(url: url)
    }

    func getValidFiles(_ result: Result<[URL], any Error>) async throws -> [URL] {
        return try await fileOpeningService.getValidFiles(result)
    }

    func openOrCreateContainer(urls: [URL], isSivaConfirmed: Bool) async throws -> SignedContainerProtocol {
        return try await fileOpeningService.openOrCreateContainer(dataFiles: urls, isSivaConfirmed: isSivaConfirmed)
    }

    func openOrCreateCryptoContainer(urls: [URL]) async throws -> CryptoContainerProtocol {
        return try await fileOpeningService.openOrCreateCryptoContainer(dataFiles: urls)
    }

    func isSivaConfirmationNeeded(files: [URL]) async -> Bool {
        return await sivaService.isSivaConfirmationNeeded(files: files)
    }
}
