// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import UtilsLib
import Foundation
import Observation

@Observable
@MainActor
class SigningRootViewModel: SigningRootViewModelProtocol, Loggable {

    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
    }

    func getSelectedSigningMethod() async -> ActionMethod {
        return await dataStore.getSelectedSigningMethod()
    }
}
