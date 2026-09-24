// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import Observation
import UtilsLib

@Observable
@MainActor
class DecryptRootViewModel: DecryptRootViewModelProtocol, Loggable {

    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
    }

    func getSelectedDecryptMethod() async -> ActionMethod {
        return await dataStore.getSelectedDecryptMethod()
    }
}
