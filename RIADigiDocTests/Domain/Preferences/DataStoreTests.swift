import Testing

struct DataStoreTests {
    private let dataStore: DataStoreProtocol

    init() {
        dataStore = DataStore()
    }

    // MARK: - Language Tests

    @Test
    func getSelectedLanguage_success() async throws {
        let allowedLanguageCodes: [String] = ["en", "et"]
        let selectedLanguage: String = await dataStore.getSelectedLanguage()
        #expect(allowedLanguageCodes.contains(selectedLanguage))
    }

    @Test
    func setSelectedLanguage_success() async throws {
        let testLanguageCode: String = "et"
        await dataStore.setSelectedLanguage(newLanguageCode: testLanguageCode)
        #expect(await dataStore.getSelectedLanguage() == testLanguageCode)
    }

    // MARK: - Theme Tests

    @Test
    func getSelectedTheme_success() async throws {
        let allowedThemeRawValues: [Int] = [0, 1, 2]
        let selectedTheme: Int = await dataStore.getSelectedTheme()
        #expect(allowedThemeRawValues.contains(selectedTheme))
    }

    @Test
    func setSelectedTheme_success() async throws {
        let testThemeRawValue: Int = 2
        await dataStore.setSelectedTheme(testThemeRawValue)
        #expect(await dataStore.getSelectedTheme() == testThemeRawValue)
    }
}
