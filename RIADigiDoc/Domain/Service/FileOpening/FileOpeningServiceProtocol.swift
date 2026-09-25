// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift
import CryptoSwift

/// @mockable
public protocol FileOpeningServiceProtocol: Sendable {
    func isFileSizeValid(url: URL) async throws -> Bool
    func getValidFiles(_ result: Result<[URL], Error>) async throws -> [URL]
    func openOrCreateContainer(dataFiles: [URL], isSivaConfirmed: Bool) async throws -> SignedContainerProtocol
    func openOrCreateCryptoContainer(dataFiles: [URL]) async throws -> CryptoContainerProtocol
}
