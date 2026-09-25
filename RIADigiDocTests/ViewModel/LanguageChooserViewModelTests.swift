// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Testing

@MainActor
final class LanguageChooserViewModelTests {
    private let viewModel: LanguageChooserViewModel!

    private let mockLanguageSettings: LanguageSettingsProtocolMock!

    init() {
        mockLanguageSettings = LanguageSettingsProtocolMock()

        viewModel = LanguageChooserViewModel(languageSettings: mockLanguageSettings)
    }

    // MARK: - Tests

    @Test
    func selectLanguage_success() async throws {
        await viewModel.selectLanguage(code: "en")
        #expect(mockLanguageSettings.setSelectedLanguageCallCount == 1)
    }
}
