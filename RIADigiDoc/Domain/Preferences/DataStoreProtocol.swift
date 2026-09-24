// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import ConfigLib

/// @mockable
public protocol DataStoreProtocol: Sendable {
    func keyExists(_ key: String) async -> Bool

    // MARK: - Skip Language Selector
    func getIsInitialLanguageSelected() async -> Bool
    func setIsInitialLanguageSelected(_ value: Bool) async

    // MARK: - Language Methods
    func getSelectedLanguage() async -> String
    func setSelectedLanguage(newLanguageCode: String) async

    // MARK: - Theme Methods
    func getSelectedTheme() async -> Int
    func setSelectedTheme(_ rawValue: Int) async

    // MARK: - Restore Default Services Settings
    func getCentralCDOC2Conf(
        _ uuid: String,
        configuration: ConfigurationProvider?
    ) async -> EncryptionServerInfo
    func restoreDefaultServicesSettings(_ configuration: ConfigurationProvider?) async

    // MARK: - Validation Service Settings Methods
    func getValidationServiceURL() async -> String
    func setValidationServiceURL(validationServiceURL: String) async
    func getValidationServiceOption() async -> ServicesSettingsOption
    func setValidationServiceOption(_ option: ServicesSettingsOption) async

    // MARK: - TSA URL Methods
    func getTSAUrl() async -> String
    func setTSAUrl(tsaUrl: String) async
    func getTSAUrlOption() async -> ServicesSettingsOption
    func setTSAUrlOption(_ option: ServicesSettingsOption) async

    // MARK: - Relying Party UUID Methods
    func getRelyingPartyUUID() async -> String
    func setRelyingPartyUUID(relyingPartyUUID: String) async
    func getRelyingPartyOption() async -> ServicesSettingsOption
    func setRelyingPartyOption(_ option: ServicesSettingsOption) async

    // MARK: - Encryption Service Settings Methods
    func getEncryptionCdocOption(_ cdoc2Default: Bool) async -> EncryptionCdocOption
    func setEncryptionCdocOption(_ option: EncryptionCdocOption) async
    func getUseCdoc2Encryption(_ cdoc2Default: Bool) async -> Bool
    func setUseCdoc2Encryption(_ value: Bool) async
    func keyExistsUseCdoc2Encryption() async -> Bool
    func getEncryptionUseKeyTransfer(_ cdoc2UseKeyserver: Bool) async -> Bool
    func setEncryptionUseKeyTransfer(_ value: Bool) async
    func keyExistsEncryptionUseKeyTransfer() async -> Bool
    func getEncryptionServerId(_ defaultVal: String?) async -> String
    func setEncryptionServerId(_ option: String) async
    func getEncryptionServerInfo(_ encryptionServerInfoUUID: String?) async -> EncryptionServerInfo
    func setEncryptionServerInfo(_ info: EncryptionServerInfo) async
    func keyExistsEncryptionServerInfo() async -> Bool
    func setEncryptionServerInfoFetchURL(_ url: String, domain: String) async
    func setEncryptionServerInfoPostURL(_ url: String, domain: String) async

    // MARK: - Proxy Service Settings Methods
    func getProxyInfo() async -> ProxyInfo
    func setProxyInfo(_ info: ProxyInfo) async

    // MARK: - Decrypt Selection Methods
    func getSelectedDecryptMethod() async -> ActionMethod
    func setSelectedDecryptMethod(_ method: ActionMethod) async

    // MARK: - Signing Selection Methods
    func getSelectedSigningMethod() async -> ActionMethod
    func setSelectedSigningMethod(_ method: ActionMethod) async

    func getSelectedMyEidMethod() async -> ActionMethod
    func setSelectedMyEidMethod(_ method: ActionMethod) async

    // MARK: - Mobile-ID Input Methods
    func getMobileIdInputData() async -> MobileIdInputData
    func setMobileIdInputData(_ inputData: MobileIdInputData) async

    // MARK: - Smart-ID Input Methods
    func getSmartIdInputData() async -> SmartIdInputData
    func setSmartIdInputData(_ inputData: SmartIdInputData) async

    // MARK: - Role And Address Methods
    func getIsRoleAndAddressEnabled() async -> Bool
    func setIsRoleAndAddressEnabled(_ isEnabled: Bool) async
    func getRoleData() async -> RoleData
    func setRoleData(_ roleData: RoleData) async

    // MARK: - NFC Input Methods
    func getNFCRememberMe() async -> Bool
    func setNFCRememberMe(_ value: Bool) async

    // MARK: - Logging
    func getEnableLoggingNextSession() async -> Bool
    func setEnableLoggingNextSession(_ isEnabled: Bool) async
    func getEnableLoggingThisSession() async -> Bool
    func setEnableLoggingThisSession(_ isEnabled: Bool) async
    func getIsLogFileSaved() async -> Bool
    func setIsLogFileSaved(_ isSaved: Bool) async

    // MARK: - Crashlytics
    func getIsCrashlyticsAlwaysEnabled() async -> Bool
    func setIsCrashlyticsAlwaysEnabled(_ isEnabled: Bool) async

    // MARK: - LTA Settings
    func getIsDefaultLTAEnabled() async -> Bool
    func setIsDefaultLTAEnabled(_ isEnabled: Bool) async

    // MARK: - Migration
    func getIsRecentDocumentsMigrationDone() async -> Bool
    func setIsRecentDocumentsMigrationDone(_ isDone: Bool) async

    // MARK: - Web eID
    func getWebEidRememberMe() async -> Bool
    func setWebEidRememberMe(_ value: Bool) async
}
