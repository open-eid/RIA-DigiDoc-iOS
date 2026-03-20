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

import Testing

@MainActor
final class InitViewModelTests {
    private let viewModel: InitViewModel!

    private let mockLanguageSettings: LanguageSettingsProtocolMock!
    private let mockDataStore: DataStoreProtocolMock!

    init() {
        mockLanguageSettings = LanguageSettingsProtocolMock()
        mockDataStore = DataStoreProtocolMock()

        mockDataStore.getIsInitialLanguageSelectedHandler = {
            false
        }

        viewModel = InitViewModel(languageSettings: mockLanguageSettings, dataStore: mockDataStore)
    }

    @Test
    func selectLanguage_success() async throws {
        let languageCode = "en"
        await viewModel.selectLanguage(code: languageCode)

        #expect(mockLanguageSettings.setSelectedLanguageCallCount == 1)
        #expect(mockLanguageSettings.setSelectedLanguageArgValues.count == 1)
        #expect(mockLanguageSettings.setSelectedLanguageArgValues.first == languageCode)

        #expect(mockDataStore.setIsInitialLanguageSelectedCallCount == 1)
        #expect(mockDataStore.setIsInitialLanguageSelectedArgValues.count == 1)
        #expect(mockDataStore.setIsInitialLanguageSelectedArgValues.first == true)
    }
}
