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
import OSLog
import LibdigidocLibSwift

@MainActor
class HomeViewModel: HomeViewModelProtocol, ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "HomeViewModel")

    @Published var isImporting = false
    @Published var signedContainer: SignedContainerProtocol = SignedContainer(
        fileManager: Container.shared.fileManager(),
        containerUtil: Container.shared.containerUtil()
    )

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool {
        if !isImportingValue && !isFileOpeningLoading {
            HomeViewModel.logger.info("User cancelled the file chooser")
            return true
        }

        return false
    }

    func setChosenFiles(_ chosenFiles: Result<[URL], Error>) {
        sharedContainerViewModel.setFileOpeningResult(fileOpeningResult: chosenFiles)
    }
}
