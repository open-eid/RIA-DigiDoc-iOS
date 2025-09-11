import Testing

struct LanguageSettingsTests {
    private let mockDataStore: DataStoreProtocolMock

    private let languageSettings: LanguageSettingsProtocol

    init() async {
        mockDataStore = DataStoreProtocolMock()

        languageSettings = await LanguageSettings(dataStore: mockDataStore)
    }

    // MARK: - Tests

    @Test
    func getSelectedLanguage_success() async throws {
        let allowedLanguageCodes: [String] = ["en", "et"]
        let selectedLanguage: String = await languageSettings.getSelectedLanguage()
        #expect(allowedLanguageCodes.contains(selectedLanguage))
    }

    @Test
    func setSelectedLanguage_success() async throws {
        let testLanguageCode: String = "et"

        mockDataStore.getSelectedLanguageHandler = {
            return testLanguageCode
        }

        await languageSettings.setSelectedLanguage(newLanguageCode: testLanguageCode)

        #expect(await languageSettings.getSelectedLanguage() == testLanguageCode)
        #expect(mockDataStore.setSelectedLanguageCallCount == 1)
    }
}
