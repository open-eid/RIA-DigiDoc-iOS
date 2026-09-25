// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift

/// @mockable
public protocol SivaRepositoryProtocol: Sendable {
    func isSivaConfirmationNeeded(files: [URL]) async -> Bool
    func isTimestampedContainer(signedContainer: SignedContainerProtocol) async -> Bool
    func getTimestampedContainer(
        parentContainer: SignedContainerProtocol
    ) async throws -> SignedContainerProtocol
}

extension SivaRepositoryProtocol {
    func shouldOpenNestedTimestampedContainer(_ container: SignedContainerProtocol) async -> Bool {
        guard await isTimestampedContainer(signedContainer: container) else { return false }
        let isCades = await container.isCades()
        let isXades = await container.isXades()
        guard !isCades, !isXades else { return false }
        guard let containerFile = await container.getRawContainerFile() else { return false }
        return await isSivaConfirmationNeeded(files: [containerFile])
    }
}
