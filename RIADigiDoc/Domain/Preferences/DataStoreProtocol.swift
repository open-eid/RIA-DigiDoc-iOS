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

import CommonsLib

/// @mockable
public protocol DataStoreProtocol: Sendable {
    // MARK: - Language Methods
    func getSelectedLanguage() async -> String
    func setSelectedLanguage(newLanguageCode: String) async

    // MARK: - Theme Methods
    func getSelectedTheme() async -> Int
    func setSelectedTheme(_ rawValue: Int) async

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
    func getEncryptionCdocOption() async -> EncryptionCdocOption
    func setEncryptionCdocOption(_ option: EncryptionCdocOption) async
    func getEncryptionUseKeyTransfer() async -> Bool
    func setEncryptionUseKeyTransfer(_ value: Bool) async
    func getEncryptionServerId() async -> EncryptionServerOptionId
    func setEncryptionServerId(_ option: EncryptionServerOptionId) async
    func getEncryptionServerInfo() async -> EncryptionServerInfo
    func setEncryptionServerInfo(_ info: EncryptionServerInfo) async

    // MARK: - Proxy Service Settings Methods
    func getProxyInfo() async -> ProxyInfo
    func setProxyInfo(_ info: ProxyInfo) async

    // MARK: - Signing Selection Methods
    func getSelectedSigningMethod() async -> SigningMethod
    func setSelectedSigningMethod(_ method: SigningMethod) async

    // MARK: - Mobile-ID Input Methods
    func getMobileIdInputData() async -> MobileIdInputData
    func setMobileIdInputData(_ inputData: MobileIdInputData) async

    // MARK: - Smart-ID Input Methods
    func getSmartIdInputData() async -> SmartIdInputData
    func setSmartIdInputData(_ inputData: SmartIdInputData) async
}
