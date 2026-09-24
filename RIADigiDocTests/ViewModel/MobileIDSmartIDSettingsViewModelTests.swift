// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import Testing

@MainActor
final class MobileIDSmartIDSettingsViewModelTests {
    private let mockDataStore: DataStoreProtocolMock!

    init() {
        mockDataStore = DataStoreProtocolMock()

        mockDataStore.getRelyingPartyUUIDHandler = {
            return Constants.Signing.RelyingPartyUUID
        }
        mockDataStore.getRelyingPartyOptionHandler = {
            return .defaultSetting
        }
    }

    // MARK: - Tests

    @Test
    func saveSettings_successDefaultSetting() async throws {
        let viewModel = MobileIDSmartIDSettingsViewModel(dataStore: mockDataStore)
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
        let viewModel = MobileIDSmartIDSettingsViewModel(dataStore: mockDataStore)

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
        let testUUID = "00000000-0000-0000-0000-000000000001"
        let viewModel = MobileIDSmartIDSettingsViewModel(dataStore: mockDataStore)

        mockDataStore.getRelyingPartyOptionHandler = {
            return .manualSetting
        }

        mockDataStore.getRelyingPartyUUIDHandler = { testUUID }

        await viewModel.loadSettings()
        await viewModel.saveSettings()

        #expect(mockDataStore.setRelyingPartyUUIDCallCount == 1)
        #expect(mockDataStore.setRelyingPartyOptionCallCount == 1)

        #expect(viewModel.relyingPartyUUID == testUUID)
    }
}
