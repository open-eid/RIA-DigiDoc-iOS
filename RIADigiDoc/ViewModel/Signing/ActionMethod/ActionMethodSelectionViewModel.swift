// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import UtilsLib
import Foundation

@Observable
@MainActor
class ActionMethodSelectionViewModel: ActionMethodSelectionViewModelProtocol, Loggable {
    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
    }

    func setSelectedSigningMethod(_ method: ActionMethod) async {
        await dataStore.setSelectedSigningMethod(method)
    }

    func getSelectedSigningMethod() async -> ActionMethod {
        await dataStore.getSelectedSigningMethod()
    }

    func setSelectedMyEidMethod(_ method: ActionMethod) async {
        await dataStore.setSelectedMyEidMethod(method)
    }

    func getSelectedMyEidMethod() async -> ActionMethod {
        await dataStore.getSelectedMyEidMethod()
    }

    func setSelectedDecryptMethod(_ method: ActionMethod) async {
        await dataStore.setSelectedDecryptMethod(method)
    }

    func getSelectedDecryptMethod() async -> ActionMethod {
        await dataStore.getSelectedDecryptMethod()
    }
}
