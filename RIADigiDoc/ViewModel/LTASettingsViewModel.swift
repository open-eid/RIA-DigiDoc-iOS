// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

@Observable
@MainActor
class LTASettingsViewModel: LTASettingsViewModelProtocol {

    var isDefaultLTAEnabled: Bool = false

    private let dataStore: DataStoreProtocol

    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
        Task {
            await loadSettings()
        }
    }

    func loadSettings() async {
        self.isDefaultLTAEnabled = await dataStore.getIsDefaultLTAEnabled()
    }

    func saveSettings() async {
        await dataStore.setIsDefaultLTAEnabled(isDefaultLTAEnabled)
    }
}
