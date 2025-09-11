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
        viewModel.selectLanguage(code: "en")
        #expect(mockLanguageSettings.setSelectedLanguageCallCount == 1)
    }
}
