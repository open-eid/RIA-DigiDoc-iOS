// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import UtilsLib
import Foundation
import Observation
import CommonsLib
import LibdigidocLibSwift

@Observable
@MainActor
class SigningRootViewModel: SigningRootViewModelProtocol, Loggable {

    private let dataStore: DataStoreProtocol
    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    init(
        dataStore: DataStoreProtocol,
        sharedContainerViewModel: SharedContainerViewModelProtocol
    ) {
        self.dataStore = dataStore
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    func getSelectedSigningMethod() async -> ActionMethod {
        return await dataStore.getSelectedSigningMethod()
    }

    func applySignedContainer(
        _ signedContainer: SignedContainerProtocol,
        replacing containerBeingSigned: GeneralContainer?
    ) {
        guard let containerBeingSigned,
              sharedContainerViewModel.currentContainer() === containerBeingSigned else {
            SigningRootViewModel.logger().info(
                "Container was replaced while signing. Dropping the signed container"
            )
            return
        }

        sharedContainerViewModel.removeLastContainer()
        sharedContainerViewModel.setSignedContainer(signedContainer)
        sharedContainerViewModel.setIsSignatureAdded(true)
    }
}
