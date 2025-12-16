/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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
import CommonsLib

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

    // MARK: - Is Initial Langauge Selected Tests
    @Test
    func getIsInitialLanguageSelected_success() async throws {
        #expect(!(await dataStore.getIsInitialLanguageSelected()))
    }

    @Test
    func setIsInitialLanguageSelected_success() async throws {
        let expectedValue1: Bool = true
        await dataStore.setIsInitialLanguageSelected(expectedValue1)
        #expect(await dataStore.getIsInitialLanguageSelected() == expectedValue1)
        let expectedValue2: Bool = false
        await dataStore.setIsInitialLanguageSelected(expectedValue2)
        #expect(await dataStore.getIsInitialLanguageSelected() == expectedValue2)
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

    // MARK: - Restore Default Services Settings Tests
    @Test
    func restoreDefaultServicesSettings_success() async throws {
        await dataStore.restoreDefaultServicesSettings(nil)

        #expect(await dataStore.getValidationServiceURL() == "")
        #expect(await dataStore.getValidationServiceOption() == .defaultSetting)
        #expect(await dataStore.getTSAUrl() == "")
        #expect(await dataStore.getTSAUrlOption() == .defaultSetting)
        #expect(await dataStore.getRelyingPartyUUID() == CommonsLib.Constants.Signing.RelyingPartyUUID)
        #expect(await dataStore.getRelyingPartyOption() == .defaultSetting)
        #expect(await dataStore.getEncryptionCdocOption(false) == .cdoc1)
        #expect(await dataStore.getEncryptionUseKeyTransfer(false) == false)
        #expect(await dataStore.getEncryptionServerId(nil) == Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        let encryptionServerInfo: EncryptionServerInfo = await dataStore.getEncryptionServerInfo(nil)
        #expect(encryptionServerInfo.uuid == Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        #expect(encryptionServerInfo.name == "")
        #expect(encryptionServerInfo.fetchURL == "")
        #expect(encryptionServerInfo.postURL == "")
        let proxyInfo = await dataStore.getProxyInfo()
        #expect(proxyInfo.option == .disabled)
        #expect(proxyInfo.host == "")
        #expect(proxyInfo.port == 80)
        #expect(proxyInfo.username == "")
        #expect(proxyInfo.password == "")
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

    // MARK: - Encryption Service Settings Methods

    @Test
    func getEncryptionCdocOption_success() async throws {
        let retrievedOption = await dataStore.getEncryptionCdocOption(false)
        let allowedOptions: [EncryptionCdocOption] = [
            .cdoc1,
            .cdoc2
        ]
        #expect(allowedOptions.contains(retrievedOption))
    }

    @Test
    func setEncryptionCdocOption_success() async throws {
        await dataStore.setEncryptionCdocOption(.cdoc1)
        #expect(await dataStore.getEncryptionCdocOption(false) == .cdoc1)
        await dataStore.setEncryptionCdocOption(.cdoc2)
        #expect(await dataStore.getEncryptionCdocOption(false) == .cdoc2)
    }

    @Test
    func getEncryptionUseKeyTransfer_success() async throws {
        let retrieved = await dataStore.getEncryptionUseKeyTransfer(false)
        #expect(retrieved == false)
    }

    @Test
    func setEncryptionUseKeyTransfer_success() async throws {
        await dataStore.setEncryptionUseKeyTransfer(true)
        #expect(await dataStore.getEncryptionUseKeyTransfer(false) == true)
        await dataStore.setEncryptionUseKeyTransfer(false)
        #expect(await dataStore.getEncryptionUseKeyTransfer(false) == false)
    }

    @Test
    func getEncryptionServerId_success() async throws {
        let retrievedOption = await dataStore.getEncryptionServerId(nil)
        let allowedOptions: [String] = [
            "10000000-0000-0000-0000-000000000000",
            Constants.CryptoDefaultValues.encryptionServerInfoUUID
        ]
        #expect(allowedOptions.contains(retrievedOption))
    }

    @Test
    func setEncryptionServerId_success() async throws {
        await dataStore.setEncryptionServerId(Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        #expect(await dataStore.getEncryptionServerId(nil) == Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        await dataStore.setEncryptionServerId("10000000-0000-0000-0000-000000000000")
        #expect(await dataStore.getEncryptionServerId(nil) == "10000000-0000-0000-0000-000000000000")
    }

    @Test
    func getEncryptionServerInfo_success() async throws {
        let retrievedInfo = await dataStore.getEncryptionServerInfo(nil)

        #expect(retrievedInfo.uuid == Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        #expect(retrievedInfo.name == Constants.CryptoDefaultValues.encryptionServerInfoName)
        #expect(retrievedInfo.fetchURL == Constants.CryptoDefaultValues.encryptionServerInfoFetchURL)
        #expect(retrievedInfo.postURL == Constants.CryptoDefaultValues.encryptionServerInfoPostURL)

    }

    @Test
    func setEncryptionServerInfo_success() async throws {
        let testInfo = EncryptionServerInfo(
            uuid: "testUUID",
            name: "testName",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )

        await dataStore.setEncryptionServerInfo(testInfo)
        let retrievedInfo = await dataStore.getEncryptionServerInfo(nil)
        #expect(testInfo.uuid == retrievedInfo.uuid)
        #expect(testInfo.name == retrievedInfo.name)
        #expect(testInfo.fetchURL == retrievedInfo.fetchURL)
        #expect(testInfo.postURL == retrievedInfo.postURL)
    }

    @Test
    func getProxyInfo_success() async throws {
        let retrievedInfo = await dataStore.getProxyInfo()

        #expect(retrievedInfo.option == .disabled)
        #expect(retrievedInfo.host == "")
        #expect(retrievedInfo.port == 80)
        #expect(retrievedInfo.username == "")
        #expect(retrievedInfo.password == "")
    }

    @Test
    func setProxyInfo_success() async throws {
        let testInfo = ProxyInfo(
            option: .manual,
            host: "testHost",
            port: 1234,
            username: "testUser",
            password: "testPassword"
        )

        await dataStore.setProxyInfo(testInfo)
        let retrievedInfo = await dataStore.getProxyInfo()
        #expect(retrievedInfo.option == testInfo.option)
        #expect(retrievedInfo.host == testInfo.host)
        #expect(retrievedInfo.port == testInfo.port)
        #expect(retrievedInfo.username == testInfo.username)
        #expect(retrievedInfo.password == "")
    }

    // MARK: - Role Data Tests

    @Test
    func getIsRoleAndAddressEnabled_success() async throws {
        let isRoleDataEnabled = await dataStore.getIsRoleAndAddressEnabled()
        #expect(!isRoleDataEnabled)
    }

    @Test
    func setIsRoleAndAddressEnabled_success() async throws {
        await dataStore.setIsRoleAndAddressEnabled(true)
        #expect(await dataStore.getIsRoleAndAddressEnabled())
    }

    @Test
    func getRoleData_success() async throws {
        let roleData = await dataStore.getRoleData()
        #expect(roleData.roles.isEmpty)
        #expect(roleData.city.isEmpty)
        #expect(roleData.state.isEmpty)
        #expect(roleData.country.isEmpty)
        #expect(roleData.zipCode.isEmpty)
    }

    @Test
    func setRoleData_success() async throws {
        await dataStore.setRoleData(
            RoleData(
                roles: ["Role 1", "Role 2"],
                city: "Test city",
                state: "Test state",
                country: "Test country",
                zipCode: "Test zip code"
            )
        )

        let roleData = await dataStore.getRoleData()
        #expect(roleData.roles == ["Role 1", "Role 2"])
        #expect(roleData.city == "Test city")
        #expect(roleData.state == "Test state")
        #expect(roleData.country == "Test country")
    }
}
