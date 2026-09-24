// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import UtilsLib

@Observable
@MainActor
class MobileIDSmartIDSettingsViewModel: MobileIDSmartIDSettingsViewModelProtocol, Loggable {
    var relyingPartyUUID: String = ""
    var selectedOption: ServicesSettingsOption = .defaultSetting

    private let dataStore: DataStoreProtocol

    init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore

        Task {
            await loadSettings()
        }
    }

    // MARK: - Loading

    public func loadSettings() async {
        self.relyingPartyUUID = await dataStore.getRelyingPartyUUID()
        self.selectedOption = await dataStore.getRelyingPartyOption()
    }

    // MARK: - Setters

    public func saveSettings() async {
        await dataStore.setRelyingPartyOption(selectedOption)
        relyingPartyUUID = relyingPartyUUID.trimmingCharacters(in: .whitespacesAndNewlines)

        if selectedOption == .defaultSetting || relyingPartyUUID.isEmpty {
            relyingPartyUUID = Constants.Signing.RelyingPartyUUID
        }

        await dataStore.setRelyingPartyUUID(relyingPartyUUID: relyingPartyUUID)
    }
}
