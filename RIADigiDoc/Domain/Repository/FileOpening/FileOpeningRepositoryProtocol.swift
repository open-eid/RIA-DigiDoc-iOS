// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CryptoSwift
import LibdigidocLibSwift

/// @mockable
public protocol FileOpeningRepositoryProtocol: Sendable {
    func isFileSizeValid(url: URL) async throws -> Bool
    func getValidFiles(_ result: Result<[URL], Error>) async throws -> [URL]
    func openOrCreateContainer(urls: [URL], isSivaConfirmed: Bool) async throws -> SignedContainerProtocol
    func openOrCreateCryptoContainer(urls: [URL]) async throws -> CryptoContainerProtocol
    func isSivaConfirmationNeeded(files: [URL]) async -> Bool
}
