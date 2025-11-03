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
import CommonsLib

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

    public func getEncryptionCdocOption() async -> EncryptionCdocOption {
        let raw = userDefaults().integer(forKey: Keys.encryptionCdocOption)
        return EncryptionCdocOption(rawValue: raw) ?? DefaultValues.encryptionCdocOption
    }

    public func setEncryptionCdocOption(_ option: EncryptionCdocOption) async {
        userDefaults().set(option.rawValue, forKey: Keys.encryptionCdocOption)
    }

    public func getEncryptionUseKeyTransfer() async -> Bool {
        let value = userDefaults().bool(forKey: Keys.encryptionUseKeyTransfer)
        return value
    }

    public func setEncryptionUseKeyTransfer(_ value: Bool) async {
        userDefaults().set(value, forKey: Keys.encryptionUseKeyTransfer)
    }

    public func getEncryptionServerId() async -> EncryptionServerOptionId {
        let raw = userDefaults().integer(forKey: Keys.encryptionServerId)
        return EncryptionServerOptionId(rawValue: raw) ?? DefaultValues.encryptionServerId
    }

    public func setEncryptionServerId(_ option: EncryptionServerOptionId) async {
        userDefaults().set(option.rawValue, forKey: Keys.encryptionServerId)
    }

    public func getEncryptionServerInfo() async -> EncryptionServerInfo {
        let uuid = userDefaults().string(forKey: Keys.encryptionServerInfoUUID) ??
        DefaultValues.encryptionServerInfoUUID

        let fetchURL = userDefaults().string(forKey: Keys.encryptionServerInfoFetchURL) ??
        DefaultValues.encryptionServerInfoFetchURL

        let postURL = userDefaults().string(forKey: Keys.encryptionServerInfoPostURL) ??
        DefaultValues.encryptionServerInfoPostURL

        return await EncryptionServerInfo(uuid: uuid, fetchURL: fetchURL, postURL: postURL)
    }

    public func setEncryptionServerInfo(_ info: EncryptionServerInfo) async {
        userDefaults().set(info.uuid, forKey: Keys.encryptionServerInfoUUID)
        userDefaults().set(info.fetchURL, forKey: Keys.encryptionServerInfoFetchURL)
        userDefaults().set(info.postURL, forKey: Keys.encryptionServerInfoPostURL)
    }

    // MARK: - Proxy Service Settings Methods

    public func getProxyInfo() async -> ProxyInfo {
        let rawOption = userDefaults().integer(forKey: Keys.proxyOption)
        let option = ProxySettingsOption(rawValue: rawOption) ?? DefaultValues.proxyOption

        let host = userDefaults().string(forKey: Keys.proxyInfoHost) ??
        DefaultValues.proxyInfoHost

        var port = userDefaults().integer(forKey: Keys.proxyInfoPort)
        if port == 0 { port = DefaultValues.proxyInfoPort }

        let username = userDefaults().string(forKey: Keys.proxyInfoUsername) ??
        DefaultValues.proxyInfoUsername

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

    // MARK: - Signing Selection Methods

    public func getSelectedSigningMethod() async -> SigningMethod {
        if let rawValue = userDefaults().string(forKey: "selectedSigningMethod") {
            return SigningMethod(rawValue: rawValue) ??
            DefaultValues.selectedSigningMethod
        }
        return DefaultValues.selectedSigningMethod
    }

    public func setSelectedSigningMethod(_ method: SigningMethod) async {
        userDefaults().set(method.rawValue, forKey: Keys.selectedSigningMethod)
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

    // MARK: - Constants

    private enum DefaultValues {
        static let language = "en"
        static let validationServiceURL = ""
        static let tsaURL = ""
        static let relyingPartyUUID = CommonsLib.Constants.Signing.RelyingPartyUUID
        static let encryptionCdocOption: EncryptionCdocOption = .cdoc1
        static let encryptionServerId: EncryptionServerOptionId = .defaultSetting
        static let encryptionServerInfoUUID = ""
        static let encryptionServerInfoFetchURL = ""
        static let encryptionServerInfoPostURL = ""
        static let proxyOption: ProxySettingsOption = .disabled
        static let proxyInfoHost = ""
        static let proxyInfoPort = 80
        static let proxyInfoUsername = ""
        static let mobileIdPhoneNumber = Constants.MobileId.DefaultCountryCode
        static let mobileIdPersonalCode = ""
        static let selectedSigningMethod: SigningMethod = .idCardViaNFC
    }

    private enum Keys {
        static let selectedLanguage = "selectedLanguage"
        static let selectedTheme = "selectedTheme"
        static let validationServiceURL = "validationServiceURL"
        static let validationServiceOption = "validationServiceOption"
        static let tsaUrl = "tsaUrl"
        static let tsaUrlOption = "tsaUrlOption"
        static let relyingPartyUUID = "relyingPartyUUID"
        static let relyingPartyOption = "relyingPartyOption"
        static let encryptionCdocOption = "encryptionCdocOption"
        static let encryptionUseKeyTransfer = "encryptionUseKeyTransfer"
        static let encryptionServerId = "encryptionServerId"
        static let encryptionServerInfoUUID = "encryptionServerInfoUUID"
        static let encryptionServerInfoFetchURL = "encryptionServerInfoFetchURL"
        static let encryptionServerInfoPostURL = "encryptionServerInfoPostURL"
        static let proxyOption = "proxyOption"
        static let proxyInfoHost = "proxyInfoHost"
        static let proxyInfoPort = "proxyInfoPort"
        static let proxyInfoUsername = "proxyInfoUsername"
        static let selectedSigningMethod = "selectedSigningMethod"
        static let mobileIdPhoneNumber = "mobileIdPhoneNumber"
        static let mobileIdPersonalCode = "mobileIdPersonalCode"
        static let mobileIdRememberMe = "mobileIdRememberMe"
    }
}
