/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
