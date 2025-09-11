import Testing

struct DataStoreTests {
    private let dataStore: DataStoreProtocol

    init() {
        dataStore = DataStore()
    }

    // MARK: - Tests

    @Test
    func getSelectedLanguage_success() async throws {
        let allowedLanguageCodes: [String] = ["en", "et"]
        let selectedLanguage: String = await dataStore.getSelectedLanguage()
        #expect(allowedLanguageCodes.contains(selectedLanguage))
    }

    @Test func setSelectedLanguage_success() async throws {
        let testLanguageCode: String = "et"

        await dataStore.setSelectedLanguage(newLanguageCode: testLanguageCode)

        #expect(await dataStore.getSelectedLanguage() == testLanguageCode)
    }
}
