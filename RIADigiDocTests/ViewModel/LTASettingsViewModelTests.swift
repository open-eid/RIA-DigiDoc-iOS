// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing

@MainActor
final class LTASettingsViewModelTests {

    private let mockDataStore: DataStoreProtocolMock

    init() {
        mockDataStore = DataStoreProtocolMock()
        mockDataStore.getIsDefaultLTAEnabledHandler = { false }
    }

    @Test
    func isDefaultLTAEnabled_defaultsToFalse() async {
        let viewModel = LTASettingsViewModel(dataStore: mockDataStore)

        #expect(!viewModel.isDefaultLTAEnabled)
    }

    @Test
    func loadSettings_setsIsDefaultLTAEnabledToTrue() async {
        mockDataStore.getIsDefaultLTAEnabledHandler = { true }
        let viewModel = LTASettingsViewModel(dataStore: mockDataStore)

        await viewModel.loadSettings()

        #expect(viewModel.isDefaultLTAEnabled)
    }

    @Test
    func loadSettings_setsIsDefaultLTAEnabledToFalse() async {
        mockDataStore.getIsDefaultLTAEnabledHandler = { false }
        let viewModel = LTASettingsViewModel(dataStore: mockDataStore)

        await viewModel.loadSettings()

        #expect(!viewModel.isDefaultLTAEnabled)
    }

    @Test
    func saveSettings_savesEnabledStateToDataStore() async {
        let viewModel = LTASettingsViewModel(dataStore: mockDataStore)
        viewModel.isDefaultLTAEnabled = true

        await viewModel.saveSettings()

        #expect(mockDataStore.setIsDefaultLTAEnabledCallCount == 1)
        #expect(mockDataStore.setIsDefaultLTAEnabledArgValues.first == true)
    }

    @Test
    func saveSettings_savesDisabledStateToDataStore() async {
        let viewModel = LTASettingsViewModel(dataStore: mockDataStore)
        viewModel.isDefaultLTAEnabled = false

        await viewModel.saveSettings()

        #expect(mockDataStore.setIsDefaultLTAEnabledCallCount == 1)
        #expect(mockDataStore.setIsDefaultLTAEnabledArgValues.first == false)
    }
}
