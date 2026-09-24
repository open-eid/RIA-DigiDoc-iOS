// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import UtilsLib

@Observable
@MainActor
class RoleViewModel: RoleViewModelProtocol, Loggable {

    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
    }

    func saveInputData(_ roleData: RoleData) async {
        await dataStore.setRoleData(roleData)
    }

    func getInputData() async -> RoleData {
        await dataStore.getRoleData()
    }
}
