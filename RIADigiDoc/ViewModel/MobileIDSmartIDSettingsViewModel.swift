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
