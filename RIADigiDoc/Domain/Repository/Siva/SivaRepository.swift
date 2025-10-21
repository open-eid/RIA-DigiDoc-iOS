/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

actor SivaRepository: SivaRepositoryProtocol {
    private let sivaService: SivaServiceProtocol

    init(
        sivaService: SivaServiceProtocol
    ) {
        self.sivaService = sivaService
    }

    func isSivaConfirmationNeeded(files: [URL]) async -> Bool {
        await sivaService.isSivaConfirmationNeeded(files: files)
    }

    func isTimestampedContainer(signedContainer: SignedContainerProtocol) async -> Bool {
        await sivaService.isTimestampedContainer(signedContainer: signedContainer)
    }

    func getTimestampedContainer(parentContainer: SignedContainerProtocol) async throws -> any SignedContainerProtocol {
        try await sivaService.getTimestampedContainer(parentContainer: parentContainer)
    }
}
