// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift

/// @mockable
public protocol SivaServiceProtocol: Sendable {
    func isSivaConfirmationNeeded(files: [URL]) async -> Bool
    func isTimestampedContainer(signedContainer: SignedContainerProtocol) async -> Bool
    func getTimestampedContainer(
        parentContainer: SignedContainerProtocol
    ) async throws -> SignedContainerProtocol
}
