import Foundation
import Testing

final class DataStoreTests {
    private let dataStore: DataStoreProtocol
    private let testSuiteName: String

    init() {
        testSuiteName = "TestDataStore-\(UUID().uuidString)"
        dataStore = DataStore(suiteName: testSuiteName)
    }

    deinit {
        UserDefaults().removePersistentDomain(forName: testSuiteName)
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

    // MARK: - Validation Service Settings Tests

    @Test
    func getValidationServiceURL_successWithDefaultValue() async throws {
        let retrievedUrl = await dataStore.getValidationServiceURL()
        #expect(retrievedUrl == "")
    }

    @Test
    func setValidationServiceURL_success() async throws {
        let testUrl = "https://example.com/siva"
        await dataStore.setValidationServiceURL(validationServiceURL: testUrl)
        let retrievedUrl = await dataStore.getValidationServiceURL()
        #expect(retrievedUrl == testUrl)
    }

    @Test
    func getValidationServiceOption_success() async throws {
        let retrievedOption = await dataStore.getValidationServiceOption()
        let allowedOptions: [ServicesSettingsOption] = [
            .defaultSetting,
            .manualSetting
        ]
        #expect(allowedOptions.contains(retrievedOption))
    }

    @Test
    func setValidationServiceOption_success() async throws {
        await dataStore.setValidationServiceOption(.defaultSetting)
        #expect(await dataStore.getValidationServiceOption() == .defaultSetting)
        await dataStore.setValidationServiceOption(.manualSetting)
        #expect(await dataStore.getValidationServiceOption() == .manualSetting)
    }
}
