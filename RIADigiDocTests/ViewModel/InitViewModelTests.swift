// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
