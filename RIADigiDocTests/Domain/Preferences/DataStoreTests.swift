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

    // MARK: - TSA URL Tests

    @Test
    func setTSAUrl_successWithDefaultValue() async throws {
        let retrievedUrl = await dataStore.getTSAUrl()
        #expect(retrievedUrl == "")
    }

    @Test
    func setTSAUrl_success() async throws {
        let testTSAUrl = "https://example.com/tsa"
        await dataStore.setTSAUrl(tsaUrl: testTSAUrl)
        let retrievedUrl = await dataStore.getTSAUrl()
        #expect(retrievedUrl == testTSAUrl)
    }

    @Test
    func getTSAUrlOption_success() async throws {
        let retrievedOption = await dataStore.getTSAUrlOption()
        let allowedOptions: [ServicesSettingsOption] = [
            .defaultSetting,
            .manualSetting
        ]
        #expect(allowedOptions.contains(retrievedOption))
    }

    @Test
    func setTSAUrlOption_success() async throws {
        await dataStore.setTSAUrlOption(.defaultSetting)
        #expect(await dataStore.getTSAUrlOption() == .defaultSetting)
        await dataStore.setTSAUrlOption(.manualSetting)
        #expect(await dataStore.getTSAUrlOption() == .manualSetting)
    }

    // MARK: - Relying Party UUID Tests

    @Test
    func getRelyingPartyUUID_success() async throws {
        let retrievedUUID = await dataStore.getRelyingPartyUUID()
        #expect(!retrievedUUID.isEmpty)
    }

    @Test
    func setRelyingPartyUUID_success() async throws {
        let testUUID = "550e8400-e29b-41d4-a716-446655440000"
        await dataStore.setRelyingPartyUUID(relyingPartyUUID: testUUID)
        let retrievedUUID = await dataStore.getRelyingPartyUUID()
        #expect(retrievedUUID == testUUID)
    }

    @Test
    func getRelyingPartyOption_success() async throws {
        let retrievedOption = await dataStore.getRelyingPartyOption()
        let allowedOptions: [ServicesSettingsOption] = [
            .defaultSetting,
            .manualSetting
        ]
        #expect(allowedOptions.contains(retrievedOption))
    }

    @Test
    func setRelyingPartyOption_success() async throws {
        await dataStore.setRelyingPartyOption(.defaultSetting)
        #expect(await dataStore.getRelyingPartyOption() == .defaultSetting)
        await dataStore.setRelyingPartyOption(.manualSetting)
        #expect(await dataStore.getRelyingPartyOption() == .manualSetting)
    }
}
