// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
