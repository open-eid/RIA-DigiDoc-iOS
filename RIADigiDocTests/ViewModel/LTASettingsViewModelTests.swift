/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
