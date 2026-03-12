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

import Foundation
import CommonsLib
import ConfigLib

public actor DataStore: DataStoreProtocol {
    private let suiteName: String?

    public init(suiteName: String? = nil) {
        self.suiteName = suiteName
    }

    private func userDefaults() -> UserDefaults {
        if let suiteName {
            return UserDefaults(suiteName: suiteName) ?? .standard
        }
        return .standard
    }

    public func keyExists(_ key: String) async -> Bool {
        let defaults = userDefaults()

        guard defaults.object(forKey: key) != nil else {
            return false
        }

        return true
    }

    // MARK: - Is Initial Langauge Selected

    public func getIsInitialLanguageSelected() async -> Bool {
        userDefaults().bool(forKey: Keys.isInitialLanguageSelected)
    }

    public func setIsInitialLanguageSelected(_ value: Bool) async {
        userDefaults().set(value, forKey: Keys.isInitialLanguageSelected)
    }

    // MARK: - Language Methods

    public func getSelectedLanguage() async -> String {
        userDefaults().string(forKey: Keys.selectedLanguage) ?? DefaultValues.language
    }

    public func setSelectedLanguage(newLanguageCode: String) async {
        userDefaults().set(newLanguageCode, forKey: Keys.selectedLanguage)
    }

    // MARK: - Theme Methods

    public func getSelectedTheme() async -> Int {
        return userDefaults().integer(forKey: Keys.selectedTheme)
    }

    public func setSelectedTheme(_ rawValue: Int) async {
        userDefaults().set(rawValue, forKey: Keys.selectedTheme)
    }

    // MARK: - Restore Default Services Settings

    public func getCentralCDOC2Conf(
        _ uuid: String,
        configuration: ConfigurationProvider?
    ) async -> EncryptionServerInfo {
        let confServerInfo = configuration?.cdoc2Conf
        let riaConf = confServerInfo?[uuid]
        return await EncryptionServerInfo(
            uuid: uuid,
            name: riaConf?.name ?? "",
            fetchURL: riaConf?.fetchURL.absoluteString ?? "",
            postURL: riaConf?.postURL.absoluteString ?? ""
        )
    }

    public func restoreDefaultServicesSettings(_ configuration: ConfigurationProvider?) async {
        await setValidationServiceURL(validationServiceURL: DefaultValues.validationServiceURL)
        await setValidationServiceOption(.defaultSetting)
        await setTSAUrl(tsaUrl: DefaultValues.tsaURL)
        await setTSAUrlOption(.defaultSetting)
        await setRelyingPartyUUID(relyingPartyUUID: DefaultValues.relyingPartyUUID)
        await setRelyingPartyOption(.defaultSetting)

        let cdoc2Default = configuration?.cdoc2Default ?? false
        await setEncryptionCdocOption(cdoc2Default ? .cdoc2 : .cdoc1)
        await setUseCdoc2Encryption(cdoc2Default)

        await setEncryptionUseKeyTransfer(
            configuration?.cdoc2UseKeyserver
            ?? Constants.CryptoDefaultValues.encryptionUseKeyTransfer
        )

        let defaultKeyserver = configuration?.cdoc2DefaultKeyserver
            ?? Constants.CryptoDefaultValues.encryptionServerInfoUUID
        await setEncryptionServerId(
            defaultKeyserver
        )

        let serverInfo = await getCentralCDOC2Conf(
            defaultKeyserver,
            configuration: configuration
        )

        await setEncryptionServerInfo(
            serverInfo
        )
        await setProxyInfo(ProxyInfo(
            option: DefaultValues.proxyOption,
            host: Constants.ProxyDefaultValues.proxyInfoHost,
            port: Constants.ProxyDefaultValues.proxyInfoPort,
            username: Constants.ProxyDefaultValues.proxyInfoUsername,
        ))
    }

    // MARK: - Validation Service Settings Methods

    public func getValidationServiceURL() async -> String {
        return userDefaults().string(forKey: Keys.validationServiceURL) ?? DefaultValues.validationServiceURL
    }

    public func setValidationServiceURL(validationServiceURL: String) async {
        userDefaults().set(validationServiceURL, forKey: Keys.validationServiceURL)
    }

    public func getValidationServiceOption() async -> ServicesSettingsOption {
        let raw = userDefaults().integer(forKey: Keys.validationServiceOption)
        return ServicesSettingsOption(rawValue: raw) ?? ServicesSettingsOption.defaultSetting
    }

    public func setValidationServiceOption(_ option: ServicesSettingsOption) async {
        userDefaults().set(option.rawValue, forKey: Keys.validationServiceOption)
    }

    // MARK: - TSA URL Methods

    public func getTSAUrl() async -> String {
        return userDefaults().string(forKey: Keys.tsaUrl) ?? DefaultValues.tsaURL
    }

    public func setTSAUrl(tsaUrl: String) async {
        userDefaults().set(tsaUrl, forKey: Keys.tsaUrl)
    }

    public func getTSAUrlOption() async -> ServicesSettingsOption {
        let raw = userDefaults().integer(forKey: Keys.tsaUrlOption)
        return ServicesSettingsOption(rawValue: raw) ?? ServicesSettingsOption.defaultSetting
    }

    public func setTSAUrlOption(_ option: ServicesSettingsOption) async {
        userDefaults().set(option.rawValue, forKey: Keys.tsaUrlOption)
    }

    // MARK: - Relying Party UUID Methods

    public func getRelyingPartyUUID() async -> String {
        return userDefaults().string(forKey: Keys.relyingPartyUUID) ?? DefaultValues.relyingPartyUUID
    }

    public func setRelyingPartyUUID(relyingPartyUUID: String) async {
        userDefaults().set(relyingPartyUUID, forKey: Keys.relyingPartyUUID)
    }

    public func getRelyingPartyOption() async -> ServicesSettingsOption {
        let raw = userDefaults().integer(forKey: Keys.relyingPartyOption)
        return ServicesSettingsOption(rawValue: raw) ?? ServicesSettingsOption.defaultSetting
    }

    public func setRelyingPartyOption(_ option: ServicesSettingsOption) async {
        userDefaults().set(option.rawValue, forKey: Keys.relyingPartyOption)
    }

    // MARK: - Encryption Service Settings Methods

    public func getEncryptionCdocOption(
        _ cdoc2Default: Bool
    ) async -> EncryptionCdocOption {

        let defaults = userDefaults()
        let defaultValue: EncryptionCdocOption =
            cdoc2Default ? .cdoc2 : DefaultValues.encryptionCdocOption

        guard defaults.object(forKey: Keys.encryptionCdocOption) != nil else {
            return defaultValue
        }

        let raw = defaults.integer(forKey: Keys.encryptionCdocOption)
        return EncryptionCdocOption(rawValue: raw) ?? defaultValue
    }

    public func setEncryptionCdocOption(_ option: EncryptionCdocOption) async {
        if option == .cdoc1 {
            userDefaults().set(false, forKey: Keys.encryptionUseCdoc2)
        } else {
            userDefaults().set(true, forKey: Keys.encryptionUseCdoc2)
        }

        userDefaults().set(option.rawValue, forKey: Keys.encryptionCdocOption)
    }

    public func getUseCdoc2Encryption(
        _ cdoc2Default: Bool
    ) async -> Bool {

        let defaults = userDefaults()

        guard defaults.object(forKey: Keys.encryptionUseCdoc2) != nil else {
            return cdoc2Default
        }

        return defaults.bool(forKey: Keys.encryptionUseCdoc2)
    }

    public func keyExistsUseCdoc2Encryption() async -> Bool {
        if await keyExists(Keys.encryptionUseCdoc2) {
            return true
        }
        return false
    }

    public func setUseCdoc2Encryption(_ value: Bool) async {
        userDefaults().set(value, forKey: Keys.encryptionUseCdoc2)
    }

    public func getEncryptionUseKeyTransfer(
        _ cdoc2UseKeyserver: Bool
    ) async -> Bool {

        let defaults = userDefaults()

        guard defaults.object(forKey: Keys.encryptionUseKeyTransfer) != nil else {
            return cdoc2UseKeyserver
        }

        return defaults.bool(forKey: Keys.encryptionUseKeyTransfer)
    }

    public func keyExistsEncryptionUseKeyTransfer() async -> Bool {
        if await keyExists(Keys.encryptionUseKeyTransfer) {
            return true
        }
        return false
    }

    public func setEncryptionUseKeyTransfer(_ value: Bool) async {
        userDefaults().set(value, forKey: Keys.encryptionUseKeyTransfer)
    }

    public func getEncryptionServerId(_ defaultVal: String?) async -> String {
        let defaults = userDefaults()

        guard defaults.object(forKey: Keys.encryptionServerId) != nil else {
            return defaultVal ?? Constants.CryptoDefaultValues.encryptionServerInfoUUID
        }

        let raw = defaults.string(forKey: Keys.encryptionServerId)
        return raw ?? (defaultVal ?? Constants.CryptoDefaultValues.encryptionServerInfoUUID)
    }

    public func setEncryptionServerId(_ option: String) async {
        userDefaults().set(option, forKey: Keys.encryptionServerId)
    }

    public func getEncryptionServerInfo(_ encryptionServerInfoUUID: String?) async -> EncryptionServerInfo {
        let uuid = userDefaults().string(forKey: Keys.encryptionServerInfoUUID) ??
        (encryptionServerInfoUUID ?? Constants.CryptoDefaultValues.encryptionServerInfoUUID)

        let name = userDefaults().string(forKey: Keys.encryptionServerInfoName) ??
        Constants.CryptoDefaultValues.encryptionServerInfoName

        let fetchURL = userDefaults().string(forKey: Keys.encryptionServerInfoFetchURL) ??
        Constants.CryptoDefaultValues.encryptionServerInfoFetchURL

        let postURL = userDefaults().string(forKey: Keys.encryptionServerInfoPostURL) ??
        Constants.CryptoDefaultValues.encryptionServerInfoPostURL

        return await EncryptionServerInfo(uuid: uuid, name: name, fetchURL: fetchURL, postURL: postURL)
    }

    public func setEncryptionServerInfo(_ info: EncryptionServerInfo) async {
        userDefaults().set(info.uuid, forKey: Keys.encryptionServerInfoUUID)
        userDefaults().set(info.name, forKey: Keys.encryptionServerInfoName)
        userDefaults().set(info.fetchURL, forKey: Keys.encryptionServerInfoFetchURL)
        userDefaults().set(info.postURL, forKey: Keys.encryptionServerInfoPostURL)
    }

    public func keyExistsEncryptionServerInfo() async -> Bool {
        if await keyExists(Keys.encryptionServerInfoUUID) {
            return true
        }
        return false
    }

    public func setEncryptionServerInfoFetchURL(_ url: String, domain: String) async {
        userDefaults().set(url, forKey: Keys.encryptionServerInfoFetchURL + "_" + domain)
    }

    public func setEncryptionServerInfoPostURL(_ url: String, domain: String) async {
        userDefaults().set(url, forKey: Keys.encryptionServerInfoPostURL + "_" + domain)
    }

    // MARK: - Proxy Service Settings Methods

    public func getProxyInfo() async -> ProxyInfo {
        let rawOption = userDefaults().integer(forKey: Keys.proxyOption)
        let option = ProxySettingsOption(rawValue: rawOption) ?? DefaultValues.proxyOption

        let host = userDefaults().string(forKey: Keys.proxyInfoHost) ??
        Constants.ProxyDefaultValues.proxyInfoHost

        var port = userDefaults().integer(forKey: Keys.proxyInfoPort)
        if port == 0 { port = Constants.ProxyDefaultValues.proxyInfoPort }

        let username = userDefaults().string(forKey: Keys.proxyInfoUsername) ??
        Constants.ProxyDefaultValues.proxyInfoUsername

        return ProxyInfo(
            option: option,
            host: host,
            port: port,
            username: username
        )
    }

    public func setProxyInfo(_ info: ProxyInfo) async {
        userDefaults().set(info.option.rawValue, forKey: Keys.proxyOption)
        userDefaults().set(info.host, forKey: Keys.proxyInfoHost)
        userDefaults().set(info.port, forKey: Keys.proxyInfoPort)
        userDefaults().set(info.username, forKey: Keys.proxyInfoUsername)
    }

    // MARK: - Decrypt Selection Methods

    public func getSelectedDecryptMethod() async -> ActionMethod {
        if let rawValue = userDefaults().string(forKey: Keys.selectedDecryptMethod) {
            return ActionMethod(rawValue: rawValue) ??
            DefaultValues.selectedDecryptMethod
        }
        return DefaultValues.selectedDecryptMethod
    }

    public func setSelectedDecryptMethod(_ method: ActionMethod) async {
        userDefaults().set(method.rawValue, forKey: Keys.selectedDecryptMethod)
    }

    // MARK: - Signing Selection Methods

    public func getSelectedSigningMethod() async -> ActionMethod {
        if let rawValue = userDefaults().string(forKey: Keys.selectedSigningMethod) {
            return ActionMethod(rawValue: rawValue) ??
            DefaultValues.selectedSigningMethod
        }
        return DefaultValues.selectedSigningMethod
    }

    public func setSelectedSigningMethod(_ method: ActionMethod) async {
        userDefaults().set(method.rawValue, forKey: Keys.selectedSigningMethod)
    }

    public func getSelectedMyEidMethod() async -> ActionMethod {
        if let rawValue = userDefaults().string(forKey: Keys.selectedMyEidMethod) {
            return ActionMethod(rawValue: rawValue) ??
            DefaultValues.selectedMyEidMethod
        }
        return DefaultValues.selectedMyEidMethod
    }

    public func setSelectedMyEidMethod(_ method: ActionMethod) async {
        userDefaults().set(method.rawValue, forKey: Keys.selectedMyEidMethod)
    }

    // MARK: - Mobile-ID Methods

    public func getMobileIdInputData() async -> MobileIdInputData {
        let phoneNumber = userDefaults().string(forKey: Keys.mobileIdPhoneNumber) ?? DefaultValues.mobileIdPhoneNumber
        let personalCode = userDefaults().string(
            forKey: Keys.mobileIdPersonalCode
        ) ?? DefaultValues.mobileIdPersonalCode
        let rememberMe = userDefaults().object(forKey: Keys.mobileIdRememberMe) as? Bool ?? true
        return MobileIdInputData(phoneNumber: phoneNumber, personalCode: personalCode, rememberMe: rememberMe)
    }

    public func setMobileIdInputData(_ inputData: MobileIdInputData) async {
        userDefaults().set(inputData.phoneNumber, forKey: Keys.mobileIdPhoneNumber)
        userDefaults().set(inputData.personalCode, forKey: Keys.mobileIdPersonalCode)
        userDefaults().set(inputData.rememberMe, forKey: Keys.mobileIdRememberMe)
    }

    // MARK: - Smart-ID Methods
    public func getSmartIdInputData() async -> SmartIdInputData {
        let country = (userDefaults().object(
            forKey: Keys.smartIdCountry
        ) as? SmartIdCountry) ?? DefaultValues.smartIdCountry
        let personalCode = userDefaults().string(
            forKey: Keys.smartIdPersonalCode
        ) ?? DefaultValues.smartIdPersonalCode
        let rememberMe = userDefaults().object(forKey: Keys.smartIdRememberMe) as? Bool ?? true
        return SmartIdInputData(
            country: country,
            personalCode: personalCode,
            rememberMe: rememberMe
        )
    }

    public func setSmartIdInputData(_ inputData: SmartIdInputData) async {
        userDefaults().set(inputData.country.rawValue, forKey: Keys.smartIdCountry)
        userDefaults().set(inputData.personalCode, forKey: Keys.smartIdPersonalCode)
        userDefaults().set(inputData.rememberMe, forKey: Keys.smartIdRememberMe)
    }

    public func getIsRoleAndAddressEnabled() async -> Bool {
        userDefaults().bool(forKey: Keys.roleAndAddressSetting)
    }

    public func setIsRoleAndAddressEnabled(_ isEnabled: Bool) async {
        userDefaults().set(isEnabled, forKey: Keys.roleAndAddressSetting)
    }

    public func getRoleData() async -> RoleData {
        let roles = userDefaults().string(forKey: Keys.roles) ?? DefaultValues.roles
        let city = userDefaults().string(forKey: Keys.roleCity) ?? DefaultValues.roleCity
        let state = userDefaults().string(forKey: Keys.roleState) ?? DefaultValues.roleState
        let country = userDefaults().string(forKey: Keys.roleCountry) ?? DefaultValues.roleCountry
        let zipCode = userDefaults().string(forKey: Keys.roleZipCode) ?? DefaultValues.roleZipCode

        return RoleData(
            roles: roles
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) },
            city: city,
            state: state,
            country: country,
            zipCode: zipCode
        )
    }

    public func setRoleData(_ roleData: RoleData) async {
        userDefaults().set(roleData.roles.joined(separator: ","), forKey: Keys.roles)
        userDefaults().set(roleData.city, forKey: Keys.roleCity)
        userDefaults().set(roleData.state, forKey: Keys.roleState)
        userDefaults().set(roleData.country, forKey: Keys.roleCountry)
        userDefaults().set(roleData.zipCode, forKey: Keys.roleZipCode)
    }

    public func getNFCRememberMe() async -> Bool {
        if await !keyExists(Keys.nfcRememberMe) {
            return true
        }
        return userDefaults().bool(forKey: Keys.nfcRememberMe)
    }

    public func setNFCRememberMe(_ value: Bool) async {
        userDefaults().set(value, forKey: Keys.nfcRememberMe)
    }

    // MARK: - Logging

    public func getEnableLoggingNextSession() async -> Bool {
        userDefaults().bool(forKey: Keys.enableLoggingNextSession)
    }

    public func setEnableLoggingNextSession(_ isEnabled: Bool) async {
        userDefaults().set(isEnabled, forKey: Keys.enableLoggingNextSession)
    }

    public func getEnableLoggingThisSession() async -> Bool {
        userDefaults().bool(forKey: Keys.enableLoggingThisSession)
    }

    public func setEnableLoggingThisSession(_ isEnabled: Bool) async {
        userDefaults().set(isEnabled, forKey: Keys.enableLoggingThisSession)
    }

    public func getIsLogFileSaved() async -> Bool {
        userDefaults().bool(forKey: Keys.isLogFileSaved)
    }

    public func setIsLogFileSaved(_ isSaved: Bool) async {
        userDefaults().set(isSaved, forKey: Keys.isLogFileSaved)
    }

    // MARK: - Crashlytics
    public func getIsCrashlyticsAlwaysEnabled() async -> Bool {
        userDefaults().bool(forKey: Keys.isCrashlyticsAlwaysEnabled)
    }

    public func setIsCrashlyticsAlwaysEnabled(_ isAlwaysEnabled: Bool) async {
        userDefaults().set(isAlwaysEnabled, forKey: Keys.isCrashlyticsAlwaysEnabled)
    }

    // MARK: - Migration
    public func getIsRecentDocumentsMigrationDone() async -> Bool {
        userDefaults().bool(forKey: Keys.isRecentDocumentsMigrationDone)
    }

    public func setIsRecentDocumentsMigrationDone(_ isDone: Bool) async {
        userDefaults().set(isDone, forKey: Keys.isRecentDocumentsMigrationDone)
    }

    // MARK: - Web eID

    public func getWebEidRememberMe() async -> Bool {
        userDefaults().bool(forKey: Keys.isWebEidRememberMe)
    }

    public func setWebEidRememberMe(_ value: Bool) async {
        userDefaults().set(value, forKey: Keys.isWebEidRememberMe)
    }

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
        static let validationServiceURL = ""
        static let tsaURL = ""
        static let relyingPartyUUID = CommonsLib.Constants.Signing.RelyingPartyUUID
        static let encryptionCdocOption: EncryptionCdocOption = .cdoc1
        static let proxyOption: ProxySettingsOption = .disabled
        static let selectedSigningMethod: ActionMethod = .idCardViaNFC
        static let selectedMyEidMethod: ActionMethod = .idCardViaNFC
        static let selectedDecryptMethod: ActionMethod = .idCardViaNFC
        static let mobileIdPhoneNumber = Constants.MobileId.DefaultCountryCode
        static let mobileIdPersonalCode = ""
        static let smartIdCountry = SmartIdCountry.estonia
        static let smartIdPersonalCode = ""
        static let roles = ""
        static let roleCity = ""
        static let roleState = ""
        static let roleCountry = ""
        static let roleZipCode = ""
    }

    private enum Keys {
        static let encryptionCdocOption = "encryptionCdocOption"
        static let encryptionUseCdoc2 = "encryptionUseCdoc2"
        static let encryptionUseKeyTransfer = "encryptionUseKeyTransfer"
        static let encryptionServerId = "encryptionServerId"
        static let encryptionServerInfoUUID = "encryptionServerInfoUUID"
        static let encryptionServerInfoName = "encryptionServerInfoName"
        static let encryptionServerInfoFetchURL = "encryptionServerInfoFetchURL"
        static let encryptionServerInfoPostURL = "encryptionServerInfoPostURL"
        static let encryptionCert = "encryptionCert"
        static let proxyOption = "proxyOption"
        static let proxyInfoHost = "proxyInfoHost"
        static let proxyInfoPort = "proxyInfoPort"
        static let proxyInfoUsername = "proxyInfoUsername"
        static let isInitialLanguageSelected = "isInitialLanguageSelected"
        static let selectedLanguage = "selectedLanguage"
        static let selectedTheme = "selectedTheme"
        static let validationServiceURL = "validationServiceURL"
        static let validationServiceOption = "validationServiceOption"
        static let tsaUrl = "tsaUrl"
        static let tsaUrlOption = "tsaUrlOption"
        static let relyingPartyUUID = "relyingPartyUUID"
        static let relyingPartyOption = "relyingPartyOption"
        static let selectedSigningMethod = "selectedSigningMethod"
        static let selectedMyEidMethod = "selectedMyEidMethod"
        static let selectedDecryptMethod = "selectedDecryptMethod"
        static let mobileIdPhoneNumber = "mobileIdPhoneNumber"
        static let mobileIdPersonalCode = "mobileIdPersonalCode"
        static let mobileIdRememberMe = "mobileIdRememberMe"
        static let smartIdCountry = "smartIdCountry"
        static let smartIdPersonalCode = "smartIdPersonalCode"
        static let smartIdRememberMe = "smartIdRememberMe"
        static let roleAndAddressSetting = "roleAndAddressSetting"
        static let roles = "roles"
        static let roleCity = "roleCity"
        static let roleState = "roleState"
        static let roleCountry = "roleCountry"
        static let roleZipCode = "roleZipCode"
        static let nfcRememberMe = "nfcRememberMe"
        static let enableLoggingNextSession = "enableLoggingNextSession"
        static let enableLoggingThisSession = "enableLoggingThisSession"
        static let isLogFileSaved = "isLogFileSaved"
        static let isCrashlyticsAlwaysEnabled = "isCrashlyticsAlwaysEnabled"
        static let isRecentDocumentsMigrationDone = "isRecentDocumentsMigrationDone"
        static let isWebEidRememberMe = "isWebEidRememberMe"
    }
}
