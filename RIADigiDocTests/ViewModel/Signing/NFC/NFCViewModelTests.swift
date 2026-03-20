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
import CryptoSwift
import CryptoSwiftMocks
import Foundation
import IdCardLib
import LibdigidocLibSwift
import LibdigidocLibSwiftMocks
import Testing
import UtilsLib
import UtilsLibMocks

@MainActor
final class NFCViewModelTests {
    private let viewModel: NFCViewModel!

    private let mockDataStore: DataStoreProtocolMock
    private let mockUserAgentUtil: UserAgentUtilProtocolMock
    private let mockCertificateUtil: CertificateUtilProtocolMock
    private let mockSharedMyEidSession: SharedMyEidSessionProtocolMock
    private let mockKeychainStore: KeychainStoreProtocolMock
    private let mockEncryptedDataUtil: EncryptedDataUtilProtocolMock
    private let mockOperationReadCertAndSign: OperationReadCertAndSignProtocolMock
    private let mockOperationReadCardData: OperationReadCardDataProtocolMock
    private let mockOperationDecrypt: OperationDecryptProtocolMock
    private let mockOperationWebEidSign: OperationWebEidSignProtocolMock
    private let mockOperationReadCert: OperationReadCertProtocolMock
    private let mockOperationWebEidAuth: OperationWebEidAuthProtocolMock

    private let mockNFCSessionStrings: NFCSessionStrings!

    init() async throws {
        mockDataStore = DataStoreProtocolMock()
        mockUserAgentUtil = UserAgentUtilProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()
        mockSharedMyEidSession = SharedMyEidSessionProtocolMock()
        mockKeychainStore = KeychainStoreProtocolMock()
        mockEncryptedDataUtil = EncryptedDataUtilProtocolMock()
        mockOperationReadCertAndSign = OperationReadCertAndSignProtocolMock()
        mockOperationReadCardData = OperationReadCardDataProtocolMock()
        mockOperationDecrypt = OperationDecryptProtocolMock()
        mockOperationWebEidSign = OperationWebEidSignProtocolMock()
        mockOperationReadCert = OperationReadCertProtocolMock()
        mockOperationWebEidAuth = OperationWebEidAuthProtocolMock()

        let mockLanguageSettings = LanguageSettingsProtocolMock()
        var mockNFCStringsUtil: NFCSessionStringsUtil {
            NFCSessionStringsUtil { key, args in
                mockLanguageSettings.localized(key, args)
            }
        }
        mockNFCSessionStrings = mockNFCStringsUtil.makeDefault()

        mockOperationReadCertAndSign.startOperationHandler =
        { _, _, _, _, _, _, _ in
            return SignedContainerProtocolMock()
        }

        mockOperationWebEidAuth.startOperationHandler =
        { _, _, _, _, _, _ in
            return WebEidAuthReturnData(
                authCert: Data(),
                signingCert: Data(),
                signatureArray: Data()
            )
        }
        
        mockOperationReadCert.startReadingHandler =
        { _, _ in
            return "ouput"
        }
        
        mockOperationWebEidSign.startOperationHandler =
        { _, _, _, _, _, _ , _ in
            return WebEidSignReturnData(
                signerCertB64: "",
                signatureArray: Data(),
                responseUri: ""
            )
        }
        
        viewModel = NFCViewModel(
            dataStore: mockDataStore,
            userAgentUtil: mockUserAgentUtil,
            certificateUtil: mockCertificateUtil,
            sharedMyEidSession: mockSharedMyEidSession,
            keychainStore: mockKeychainStore,
            encryptedDataUtil: mockEncryptedDataUtil,
            operationReadCertAndSign: mockOperationReadCertAndSign,
            operationWebEidAuth: mockOperationWebEidAuth,
            operationWebEidSign: mockOperationWebEidSign,
            operationReadCardData: mockOperationReadCardData,
            operationReadCert: mockOperationReadCert,
            operationDecrypt: mockOperationDecrypt
        )
    }

    // MARK: - isNFCSupported Tests

    @Test
    func isNFCSupported_returnsFalseInTestSimulator() {
        let result = viewModel.isNFCSupported()
        #expect(!result)
    }

    // MARK: - isActionEnabled Tests

    @Test
    func isActionEnabled_returnsFalseWhenCANNumberIsEmpty() {
        let result = viewModel.isActionEnabled(
            canNumber: "",
            pinNumber: "123456",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(!result)
    }

    @Test
    func isActionEnabled_returnsFalseWhenCANNumberIsInvalid() {
        let result = viewModel.isActionEnabled(
            canNumber: "12345",
            pinNumber: "123456",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(!result)
        #expect(viewModel.canNumberErrorKey == "CAN length requirement")
    }

    @Test
    func isActionEnabled_returnsFalseWhenPINNumberIsEmpty() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(!result)
    }

    @Test
    func isActionEnabled_returnsFalseWhenPINNumberIsInvalid() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "123",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(!result)
        #expect(viewModel.pinNumberErrorKey == "PIN length requirement")
    }

    @Test
    func isActionEnabled_returnsTrueWhenCANAndPINAreValid() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "12345",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(result)
        #expect(viewModel.canNumberErrorKey == "")
        #expect(viewModel.pinNumberErrorKey == "")
    }

    @Test
    func isActionEnabled_returnsTrueForMyEidWithValidCANOnly() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "",
            pinType: nil,
            actionType: .myeid
        )

        #expect(result)
    }

    @Test
    func isActionEnabled_returnsFalseForMyEidWithInvalidCAN() {
        let result = viewModel.isActionEnabled(
            canNumber: "12345",
            pinNumber: "",
            pinType: nil,
            actionType: .myeid
        )

        #expect(!result)
    }

    @Test
    func isActionEnabled_validatesCANWithNonNumericCharacters() {
        let result = viewModel.isActionEnabled(
            canNumber: "12345a",
            pinNumber: "123456",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(!result)
        #expect(viewModel.canNumberErrorKey == "CAN length requirement")
    }

    @Test
    func isActionEnabled_validatesPin1MinimumLength() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "123",
            pinType: .pin1,
            actionType: .decrypt
        )

        #expect(!result)
        #expect(viewModel.pinNumberErrorKey == "PIN length requirement")
    }

    @Test
    func isActionEnabled_validatesPin2MinimumLength() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "1234",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(!result)
        #expect(viewModel.pinNumberErrorKey == "PIN length requirement")
    }

    @Test
    func isActionEnabled_acceptsValidPin1() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "1234",
            pinType: .pin1,
            actionType: .decrypt
        )

        #expect(result)
        #expect(viewModel.pinNumberErrorKey == "")
    }

    @Test
    func isActionEnabled_acceptsValidPin2() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "12345",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(result)
        #expect(viewModel.pinNumberErrorKey == "")
    }

    @Test
    func isActionEnabled_validatesPINWithNonNumericCharacters() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "12345a",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(!result)
        #expect(viewModel.pinNumberErrorKey == "PIN length requirement")
    }

    @Test
    func isActionEnabled_ValidatesPUKMinimumLength() {
        let result = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "1234567",
            pinType: .puk,
            actionType: .signing
        )

        #expect(!result)
        #expect(viewModel.pinNumberErrorKey == "PIN length requirement")
    }

    @Test
    func errorKeys_areClearedWhenInputIsValid() {
        _ = viewModel.isActionEnabled(
            canNumber: "12345",
            pinNumber: "123",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(viewModel.canNumberErrorKey != nil)
        #expect(viewModel.pinNumberErrorKey != nil)

        _ = viewModel.isActionEnabled(
            canNumber: "123456",
            pinNumber: "12345",
            pinType: .pin2,
            actionType: .signing
        )

        #expect(viewModel.canNumberErrorKey == "")
        #expect(viewModel.pinNumberErrorKey == "")
    }

    // MARK: - resetErrors Tests

    @Test
    func resetErrors_clearsAllErrorKeys() {
        viewModel.canNumberErrorKey = "Some error"
        viewModel.canNumberErrorExtraArguments = ["arg1"]
        viewModel.pinNumberErrorKey = "Some error"
        viewModel.pinNumberErrorExtraArguments = ["arg2"]
        viewModel.nfcErrorKey = "Some error"
        viewModel.nfcErrorExtraArguments = ["arg3"]

        viewModel.resetErrors()

        #expect(viewModel.canNumberErrorKey == nil)
        #expect(viewModel.canNumberErrorExtraArguments.isEmpty)
        #expect(viewModel.pinNumberErrorKey == nil)
        #expect(viewModel.pinNumberErrorExtraArguments.isEmpty)
        #expect(viewModel.nfcErrorKey == nil)
        #expect(viewModel.nfcErrorExtraArguments.isEmpty)
    }

    // MARK: - isRoleDataEnabled Tests

    @Test
    func isRoleDataEnabled_returnsTrueWhenEnabled() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = {
            true
        }

        let result = await viewModel.isRoleDataEnabled()

        #expect(result == true)
        #expect(mockDataStore.getIsRoleAndAddressEnabledCallCount == 1)
    }

    @Test
    func isRoleDataEnabled_returnsFalseWhenDisabled() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = {
            false
        }

        let result = await viewModel.isRoleDataEnabled()

        #expect(result == false)
        #expect(mockDataStore.getIsRoleAndAddressEnabledCallCount == 1)
    }

    // MARK: - saveMyEidCAN Tests

    @Test
    func saveMyEidCAN_success() {
        mockSharedMyEidSession.setCANHandler = { _ in }

        viewModel.saveMyEidCAN("123456")

        #expect(mockSharedMyEidSession.setCANCallCount == 1)
        #expect(mockSharedMyEidSession.setCANArgValues.first == "123456")
    }

    // MARK: - saveInputData

    @Test
    func saveInputData_forAuthWithRememberMeTrue_savesWebEidRememberMeAndEncryptedCANAndClearsTempCAN() async {
        mockDataStore.setWebEidRememberMeHandler = { _ in }
        mockKeychainStore.saveKeyInfoHandler = { key, info in
            if key == .nfcCANKey {
                #expect(String(data: info, encoding: .utf8) == "123456")
            }
            return true
        }
        mockKeychainStore.removeKeyHandler = { key in
            #expect(key == .tempCANKey)
        }

        await viewModel.saveInputData(
            canNumber: "123456",
            rememberMe: true,
            actionType: .auth,
            isWebEidAuthenticating: true
        )
        #expect(mockDataStore.setWebEidRememberMeCallCount == 1)
        #expect(mockKeychainStore.saveKeyInfoCallCount >= 1)
        #expect(mockKeychainStore.removeKeyCallCount >= 1)
    }

    @Test
    func saveInputData_forSigningWithRememberMeFalse_clearsEncryptedCANAndSavesTempCAN() async {
        mockDataStore.setNFCRememberMeHandler = { _ in }
        mockKeychainStore.saveKeyInfoHandler = { key, info in
            let string = String(data: info, encoding: .utf8)
            if key == .nfcCANKey {
                #expect(string == "")
            }
            if key == .tempCANKey {
                #expect(string == "123456")
            }
            return true
        }
        mockKeychainStore.removeKeyHandler = { key in
            #expect(key == .nfcCANKey)
        }

        await viewModel.saveInputData(
            canNumber: "123456",
            rememberMe: false,
            actionType: .signing,
            isWebEidAuthenticating: false
        )

        #expect(mockDataStore.setNFCRememberMeCallCount == 1)
        #expect(mockKeychainStore.saveKeyInfoCallCount >= 2)
        #expect(mockKeychainStore.removeKeyCallCount >= 1)
    }

    @Test
    func saveInputData_forAuthWithRememberMeFalse_clearsStoredSigningCertificate() async {
        mockDataStore.setWebEidRememberMeHandler = { _ in }
        mockKeychainStore.saveKeyHandler = { _, _ in true }
        mockKeychainStore.removeKeyHandler = { _ in }
        mockKeychainStore.retrieveKeyHandler = { key in
            if key == .nfcCANKey {
                return Data("123456".utf8)
            }
            return nil
        }

        await viewModel.saveInputData(
            canNumber: "123456",
            rememberMe: false,
            actionType: .auth,
            isWebEidAuthenticating: true
        )

        #expect(mockKeychainStore.retrieveKeyCallCount >= 1)
        #expect(mockKeychainStore.saveKeyInfoCallCount >= 2)
    }

    // MARK: - getInputData

    @Test
    func getInputData_forCertificate_returnsStoredCanOnly() async {
        mockDataStore.getWebEidRememberMeHandler = { true }
        mockKeychainStore.retrieveKeyHandler = { key in
            switch key {
            case .nfcCANKey:
                return Data("654321".utf8)
            case .tempCANKey:
                return Data("123456".utf8)
            default:
                return nil
            }
        }

        let result = await viewModel.getInputData(.certificate, false)

        #expect(result.canNumber == "654321")
        #expect(result.rememberMe == true)
    }

    @Test
    func getInputData_forSigningWebEid_prefersTempCanWhenPresent() async {
        mockDataStore.getWebEidRememberMeHandler = { false }
        mockKeychainStore.retrieveKeyHandler = { key in
            switch key {
            case .nfcCANKey:
                return Data("654321".utf8)
            case .tempCANKey:
                return Data("123456".utf8)
            default:
                return nil
            }
        }

        let result = await viewModel.getInputData(.signingWebEid, false)

        #expect(result.canNumber == "123456")
        #expect(result.rememberMe == false)
    }

    @Test
    func getInputData_whenStoredCanMissingAndWebEidAuthenticating_usesTempCan() async {
        mockDataStore.getNFCRememberMeHandler = { false }
        mockKeychainStore.retrieveKeyHandler = { key in
            switch key {
            case .nfcCANKey:
                return nil
            case .tempCANKey:
                return Data("123456".utf8)
            default:
                return nil
            }
        }

        let result = await viewModel.getInputData(.signing, true)

        #expect(result.canNumber == "123456")
    }

    @Test
    func getInputData_returnsEmptyCanWhenNothingStored() async {
        mockDataStore.getNFCRememberMeHandler = { false }
        mockKeychainStore.retrieveKeyHandler = { _ in nil }

        let result = await viewModel.getInputData(.signing, false)

        #expect(result.canNumber == "")
        #expect(result.rememberMe == false)
    }

    // MARK: - keychain CAN helpers

    @Test
    func retrieveEncryptedCAN_returnsDecodedString() async {
        mockKeychainStore.retrieveKeyHandler = { key in
            #expect(key == .nfcCANKey)
            return Data("123456".utf8)
        }

        let result = await viewModel.retrieveEncryptedCAN()

        #expect(result == "123456")
    }

    @Test
    func retrieveEncryptedCAN_returnsNilForInvalidUtf8() async {
        mockKeychainStore.retrieveKeyHandler = { key in
            #expect(key == .nfcCANKey)
            return Data([0xFF, 0xFE])
        }

        let result = await viewModel.retrieveEncryptedCAN()

        #expect(result == nil)
    }

    @Test
    func clearEncryptedCAN_removesNfcCANKey() async {
        mockKeychainStore.removeKeyHandler = { key in
            #expect(key == .nfcCANKey)
        }

        await viewModel.clearEncryptedCAN()

        #expect(mockKeychainStore.removeKeyCallCount == 1)
    }

    @Test
    func retrieveTempCAN_returnsDecodedString() async {
        mockKeychainStore.retrieveKeyHandler = { key in
            #expect(key == .tempCANKey)
            return Data("123456".utf8)
        }

        let result = await viewModel.retrieveTempCAN()

        #expect(result == "123456")
    }

    @Test
    func clearTempCAN_removesTempCANKey() async {
        mockKeychainStore.removeKeyHandler = { key in
            #expect(key == .tempCANKey)
        }

        await viewModel.clearTempCAN()

        #expect(mockKeychainStore.removeKeyCallCount == 1)
    }

    // MARK: - signing certificate helpers

    @Test
    func getSigningCertificate_returnsStoredCertificateForCurrentEncryptedCAN() async {
        let expectedKey = "\(KeychainKey.signingCertKey.rawValue)_123456"

        mockKeychainStore.retrieveKeyHandler = { key in
            if key == .nfcCANKey {
                return Data("123456".utf8)
            }
            return nil
        }
        
        mockKeychainStore.retrieveHandler = { key in
            if key == expectedKey {
                return Data("cert-data".utf8)
            }
            return nil
        }

        let result = await viewModel.getSigningCertificate()

        #expect(result == "cert-data")
    }

    @Test
    func getSigningCertificate_returnsEmptyStringWhenNoEncryptedCAN() async {
        mockKeychainStore.retrieveHandler = { _ in nil }

        let result = await viewModel.getSigningCertificate()

        #expect(result == "")
    }

    @Test
    func setSigningCertificate_savesCertificateUsingCANScopedKey() async {
        let expectedKey = "\(KeychainKey.signingCertKey.rawValue)_123456"

        mockKeychainStore.retrieveKeyHandler = { key in
            if key == .nfcCANKey {
                return Data("123456".utf8)
            }
            return nil
        }

        mockKeychainStore.saveHandler = { key, info, _ in
            #expect(key == expectedKey)
            #expect(String(data: info, encoding: .utf8) == "cert-data")
            return true
        }

        await viewModel.setSigningCertificate("cert-data")

        #expect(mockKeychainStore.saveKeyCallCount == 1)
    }
    
    // MARK: - Sign Tests

    @Test
    func sign_returnsNilWhenContainerFileIsNil() async {
        let mockContainer = SignedContainerProtocolMock()
        let roleData = RoleData(
            roles: ["Test"],
            city: "",
            state: "",
            country: "",
            zipCode: ""
        )

        mockContainer.getRawContainerFileHandler = {
            nil
        }

        let result = await viewModel.sign(
            canNumber: "123456",
            pin2: "12345",
            roleData: roleData,
            signedContainer: mockContainer,
            strings: mockNFCSessionStrings
        )

        #expect(result == nil)
        #expect(mockContainer.getRawContainerFileCallCount == 1)
        #expect(mockOperationReadCertAndSign.startOperationCallCount == 0)
    }

    @Test
    func sign_success() async {
        let mockContainer = SignedContainerProtocolMock()

        let roleData = RoleData(
            roles: ["Manager", "Developer"],
            city: "Tallinn",
            state: "Harjumaa",
            country: "Estonia",
            zipCode: "10111"
        )

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/test/container.asice")
        }

        mockDataStore.getSelectedLanguageHandler = {
            "et"
        }

        mockUserAgentUtil.userAgentHandler = { _, language in
            #expect(language == "et")
            return "TestUserAgent"
        }

        _ = await viewModel.sign(
            canNumber: "123456",
            pin2: "12345",
            roleData: roleData,
            signedContainer: mockContainer,
            strings: mockNFCSessionStrings
        )

        #expect(mockContainer.getRawContainerFileCallCount == 1)
        #expect(mockDataStore.getSelectedLanguageCallCount == 1)
        #expect(mockUserAgentUtil.userAgentCallCount == 1)
        #expect(mockOperationReadCertAndSign.startOperationCallCount == 1)
        #expect(viewModel.nfcErrorKey == nil)
    }

    @Test
    func sign_setsNfcErrorKeyOnOperationFailure() async {
        let mockContainer = SignedContainerProtocolMock()

        let roleData = RoleData(
            roles: ["Manager", "Developer"],
            city: "Tallinn",
            state: "Harjumaa",
            country: "Estonia",
            zipCode: "10111"
        )

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/test/container.asice")
        }

        mockDataStore.getSelectedLanguageHandler = {
            "et"
        }

        mockUserAgentUtil.userAgentHandler = { _, language in
            #expect(language == "et")
            return "TestUserAgent"
        }

        mockOperationReadCertAndSign.startOperationHandler =
        { _, _, _, _, _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.sign(
                canNumber: "123456",
                pin2: "12345",
                roleData: roleData,
                signedContainer: mockContainer,
                strings: mockNFCSessionStrings
            )

            #expect(mockContainer.getRawContainerFileCallCount == 1)
            #expect(mockDataStore.getSelectedLanguageCallCount == 1)
            #expect(mockUserAgentUtil.userAgentCallCount == 1)
            #expect(viewModel.nfcErrorKey != nil)
        }
    }

    @Test
    func sign_errorsChangeBetweenSignCalls() async {
        let mockContainer = SignedContainerProtocolMock()
        let roleData = RoleData(
            roles: ["Test"],
            city: "",
            state: "",
            country: "",
            zipCode: ""
        )

        viewModel.nfcErrorKey = "Previous error"

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/test/container.asice")
        }

        mockDataStore.getSelectedLanguageHandler = {
            "en"
        }

        mockUserAgentUtil.userAgentHandler = { _, _ in
            "TestUserAgent"
        }

        mockOperationReadCertAndSign.startOperationHandler =
        { _, _, _, _, _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.sign(
                canNumber: "123456",
                pin2: "12345",
                roleData: roleData,
                signedContainer: mockContainer,
                strings: mockNFCSessionStrings
            )

            #expect(mockContainer.getRawContainerFileCallCount == 1)
            #expect(viewModel.nfcErrorKey != "Previous error")
        }
    }

    @Test
    func auth_success() async {
        mockDataStore.getSelectedLanguageHandler = {
            "et"
        }

        mockUserAgentUtil.userAgentHandler = { _, language in
            #expect(language == "et")
            return "TestUserAgent"
        }

        _ = await viewModel.auth(
            canNumber: "123456",
            pin1: "12345",
            origin: "origin",
            challenge: "challenge",
            strings: mockNFCSessionStrings
        )

        #expect(mockDataStore.getSelectedLanguageCallCount == 1)
        #expect(mockUserAgentUtil.userAgentCallCount == 1)
        #expect(mockOperationWebEidAuth.startOperationCallCount == 1)
        #expect(viewModel.nfcErrorKey == nil)
    }
    
    @Test
    func auth_setsNfcErrorKeyOnOperationFailure() async {
        mockDataStore.getSelectedLanguageHandler = {
            "et"
        }

        mockUserAgentUtil.userAgentHandler = { _, language in
            #expect(language == "et")
            return "TestUserAgent"
        }

        mockOperationWebEidAuth.startOperationHandler =
        { _, _, _, _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.auth(
                canNumber: "123456",
                pin1: "12345",
                origin: "origin",
                challenge: "challenge",
                strings: mockNFCSessionStrings
            )

            #expect(mockDataStore.getSelectedLanguageCallCount == 1)
            #expect(mockUserAgentUtil.userAgentCallCount == 1)
            #expect(viewModel.nfcErrorKey != nil)
        }
    }

    @Test
    func auth_errorsChangeBetweenSignCalls() async {
        viewModel.nfcErrorKey = "Previous error"

        mockDataStore.getSelectedLanguageHandler = {
            "en"
        }

        mockUserAgentUtil.userAgentHandler = { _, _ in
            "TestUserAgent"
        }

        mockOperationWebEidAuth.startOperationHandler =
        { _, _, _, _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.auth(
                canNumber: "123456",
                pin1: "12345",
                origin: "origin",
                challenge: "challenge",
                strings: mockNFCSessionStrings
            )

            #expect(viewModel.nfcErrorKey != "Previous error")
        }
    }
    
    @Test
    func certificate_success() async {
        _ = await viewModel.certificate(
            canNumber: "123456",
            strings: mockNFCSessionStrings
        )

        #expect(mockOperationReadCert.startReadingCallCount == 1)
        #expect(viewModel.nfcErrorKey == nil)
    }
    
    @Test
    func certificate_setsNfcErrorKeyOnOperationFailure() async {
        mockOperationReadCert.startReadingHandler =
        { _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.certificate(
                canNumber: "123456",
                strings: mockNFCSessionStrings
            )

            #expect(viewModel.nfcErrorKey != nil)
        }
    }

    @Test
    func certificate_errorsChangeBetweenSignCalls() async {
        viewModel.nfcErrorKey = "Previous error"

        mockOperationReadCert.startReadingHandler =
        { _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.certificate(
                canNumber: "123456",
                strings: mockNFCSessionStrings
            )

            #expect(viewModel.nfcErrorKey != "Previous error")
        }
    }
    
    @Test
    func signWebEid_success() async {
        mockDataStore.getSelectedLanguageHandler = {
            "et"
        }

        mockUserAgentUtil.userAgentHandler = { _, language in
            #expect(language == "et")
            return "TestUserAgent"
        }

        _ = await viewModel.signWebEid(
            canNumber: "123456",
            pin2: "12345",
            responseUri: "url",
            hash: "hash",
            expectedSigningCertBase64: "cert",
            strings: mockNFCSessionStrings
        )

        #expect(mockDataStore.getSelectedLanguageCallCount == 1)
        #expect(mockUserAgentUtil.userAgentCallCount == 1)
        #expect(mockOperationWebEidSign.startOperationCallCount == 1)
        #expect(viewModel.nfcErrorKey == nil)
    }
    
    @Test
    func signWebEid_setsNfcErrorKeyOnOperationFailure() async {
        mockDataStore.getSelectedLanguageHandler = {
            "et"
        }

        mockUserAgentUtil.userAgentHandler = { _, language in
            #expect(language == "et")
            return "TestUserAgent"
        }

        mockOperationWebEidSign.startOperationHandler =
        { _, _, _, _, _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.signWebEid(
                canNumber: "123456",
                pin2: "12345",
                responseUri: "url",
                hash: "hash",
                expectedSigningCertBase64: "cert",
                strings: mockNFCSessionStrings
            )

            #expect(mockDataStore.getSelectedLanguageCallCount == 1)
            #expect(mockUserAgentUtil.userAgentCallCount == 1)
            #expect(viewModel.nfcErrorKey != nil)
        }
    }

    @Test
    func signWebEid_errorsChangeBetweenSignCalls() async {
        viewModel.nfcErrorKey = "Previous error"

        mockDataStore.getSelectedLanguageHandler = {
            "en"
        }

        mockUserAgentUtil.userAgentHandler = { _, _ in
            "TestUserAgent"
        }

        mockOperationWebEidSign.startOperationHandler =
        { _, _, _, _, _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            _ = await viewModel.signWebEid(
                canNumber: "123456",
                pin2: "12345",
                responseUri: "url",
                hash: "hash",
                expectedSigningCertBase64: "cert",
                strings: mockNFCSessionStrings
            )

            #expect(viewModel.nfcErrorKey != "Previous error")
        }
    }
    
    // MARK: - decrypt

    @Test
    func decrypt_success() async {
        let mockContainer = CryptoContainerProtocolMock()
        let expectedResult = CryptoContainerProtocolMock()

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/test.cdoc")
        }
        mockContainer.getRecipientsHandler = {
            []
        }
        mockKeychainStore.removeKeyHandler = { key in
            #expect(key == .tempCANKey)
        }
        mockOperationDecrypt.processDecryptHandler = { _, _, _, _, _ in
            expectedResult
        }

        let result = await viewModel.decrypt(
            CAN: "123456",
            pin1: "1234",
            cryptoContainer: mockContainer,
            strings: mockNFCSessionStrings
        )

        #expect(result != nil)
        #expect(mockOperationDecrypt.processDecryptCallCount == 1)
        #expect(viewModel.nfcErrorKey == nil)
    }

    @Test
    func decrypt_setsGeneralErrorOnUnexpectedFailure() async {
        let mockContainer = CryptoContainerProtocolMock()

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/test.cdoc")
        }
        mockContainer.getRecipientsHandler = {
            []
        }
        mockKeychainStore.removeHandler = { _ in }
        mockOperationDecrypt.processDecryptHandler = { _, _, _, _, _ in
            throw NSError(domain: "Test", code: 1)
        }

        let result = await viewModel.decrypt(
            CAN: "123456",
            pin1: "1234",
            cryptoContainer: mockContainer,
            strings: mockNFCSessionStrings
        )

        #expect(result == nil)
        #expect(viewModel.nfcErrorKey == "NFC session error")
    }

    @Test
    func decrypt_handlesDecryptCancelledWithoutErrorKey() async {
        let mockContainer = CryptoContainerProtocolMock()

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/test.cdoc")
        }
        mockContainer.getRecipientsHandler = {
            []
        }
        mockKeychainStore.removeHandler = { _ in }
        mockOperationDecrypt.processDecryptHandler = { _, _, _, _, _ in
            throw DecryptError.cancelled
        }

        let result = await viewModel.decrypt(
            CAN: "123456",
            pin1: "1234",
            cryptoContainer: mockContainer,
            strings: mockNFCSessionStrings
        )

        #expect(result == nil)
        #expect(viewModel.nfcErrorKey == nil)
    }
    
    // MARK: - readCardData tests

    @Test
    func readCardData_success() async throws {
        let testCAN = "123456"

        let mockCardInfo = CardInfo(
            givenName: "User",
            surname: "Test",
            personalCode: "39001010000",
            citizenship: "EST",
            documentNumber: "AA1234567",
            dateOfExpiry: "31.12.2030"
        )

        let mockPinResponse = PinResponse(
            pin1RetryCount: 1,
            pin1Active: true,
            pin2RetryCount: 0,
            pin2Active: false,
            pukRetryCount: 2,
            pukActive: true
        )

        let mockNFCCardData = NFCCardData(
            publicData: mockCardInfo,
            authenticationCertificate: Data(),
            signatureCertificate: Data(),
            pinResponse: mockPinResponse,
            isPUKChangable: true
        )

        mockOperationReadCardData.startReadingHandler = { _, _ in
            return mockNFCCardData
        }

        mockCertificateUtil.getNotValidDateHandler = { _ in
            "31.11.2030"
        }

        let result = await viewModel.readCardData(
            CAN: testCAN,
            strings: mockNFCSessionStrings
        )

        #expect(result != nil)
        #expect(result?.publicData.surname == "Test")
        #expect(result?.publicData.givenName == "User")
        #expect(result?.publicData.personalCode == "39001010000")
        #expect(result?.publicData.citizenship == "EST")
        #expect(result?.publicData.documentNumber == "AA1234567")
        #expect(result?.publicData.dateOfExpiry == "31.12.2030")
        #expect(result?.pinResponse.pin1RetryCount == 1)
        #expect(result?.pinResponse.pin1Active == true)
        #expect(result?.pinResponse.pin2RetryCount == 0)
        #expect(result?.pinResponse.pin2Active == false)
        #expect(result?.pinResponse.pukRetryCount == 2)
        #expect(result?.pinResponse.pukActive == true)
        #expect(result?.isPUKChangeable == true)
        #expect(result?.authCertNotValidDate == "31.11.2030")
        #expect(result?.signCertNotValidDate == "31.11.2030")
        #expect(mockOperationReadCardData.startReadingCallCount == 1)
        #expect(mockCertificateUtil.getNotValidDateCallCount == 2)
    }
    
    @Test
    func readCardData_setsGeneralErrorOnUnexpectedFailure() async {
        mockOperationReadCardData.startReadingHandler = { _, _ in
            throw NSError(domain: "Test", code: 1)
        }

        let result = await viewModel.readCardData(
            CAN: "123456",
            strings: mockNFCSessionStrings
        )

        #expect(result == nil)
        #expect(viewModel.nfcErrorKey == "General error")
    }
}
