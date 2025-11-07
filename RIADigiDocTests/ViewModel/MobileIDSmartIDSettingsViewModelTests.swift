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
import Testing

@MainActor
final class MobileIDSmartIDSettingsViewModelTests {
    private let viewModel: MobileIDSmartIDSettingsViewModel!

    private let mockDataStore: DataStoreProtocolMock!

    init() {
        mockDataStore = DataStoreProtocolMock()

        mockDataStore.getRelyingPartyUUIDHandler = {
            return Constants.Signing.RelyingPartyUUID
        }
        mockDataStore.getRelyingPartyOptionHandler = {
            return .defaultSetting
        }

        viewModel = MobileIDSmartIDSettingsViewModel(dataStore: mockDataStore)
    }

    // MARK: - Tests

    @Test
    func saveSettings_successDefaultSetting() async throws {
        viewModel.selectedOption = .defaultSetting
        let testUUID = "00000000-0000-0000-0000-000000000001"
        viewModel.relyingPartyUUID = testUUID

        await viewModel.saveSettings()

        #expect(mockDataStore.setRelyingPartyUUIDCallCount == 1)
        #expect(mockDataStore.setRelyingPartyOptionCallCount == 1)

        #expect(viewModel.relyingPartyUUID != testUUID)
    }

    @Test
    func saveSettings_successWithManualSettingWithEmptyString() async throws {
        await viewModel.loadSettings()

        viewModel.selectedOption = .manualSetting
        let testUUID = ""
        viewModel.relyingPartyUUID = testUUID

        await viewModel.saveSettings()

        #expect(mockDataStore.setRelyingPartyUUIDCallCount == 1)
        #expect(mockDataStore.setRelyingPartyOptionCallCount == 1)

        #expect(viewModel.relyingPartyUUID == Constants.Signing.RelyingPartyUUID)
    }

    @Test
    func saveSettings_successWithManualSettingWithValidUUID() async throws {
        mockDataStore.getRelyingPartyOptionHandler = {
            return .manualSetting
        }

        await viewModel.loadSettings()

        viewModel.selectedOption = .manualSetting
        let testUUID = "00000000-0000-0000-0000-000000000001"
        viewModel.relyingPartyUUID = testUUID

        await viewModel.saveSettings()

        #expect(mockDataStore.setRelyingPartyUUIDCallCount == 1)
        #expect(mockDataStore.setRelyingPartyOptionCallCount == 1)

        #expect(viewModel.relyingPartyUUID == testUUID)
    }
}
