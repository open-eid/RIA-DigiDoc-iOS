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
