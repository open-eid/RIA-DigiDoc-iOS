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
import ConfigLib
import ConfigLibMocks
import MobileIdLib
import MobileIdLibMocks
import CommonsLib
import LibdigidocLibSwift
import LibdigidocLibSwiftMocks
import UtilsLibMocks

@MainActor
struct MobileIdViewModelTests {

    private let roleData = RoleData(
        roles: ["Role 1", "Role 2"],
        city: "Test City",
        state: "Test State",
        country: "Test Country",
        zipCode: "Test zip code"
    )

    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock
    private let mockMobileIdSignService: MobileIdSignServiceProtocolMock
    private let mockCertificatUtil: CertificateUtilProtocolMock
    private let mockDataStore: DataStoreProtocolMock
    private let mockProxyUtil: ProxyUtilProtocolMock
    private let mockUserAgentUtil: UserAgentUtilProtocolMock

    private let viewModel: MobileIdViewModel

    init() async throws {
        self.mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        self.mockMobileIdSignService = MobileIdSignServiceProtocolMock()
        self.mockCertificatUtil = CertificateUtilProtocolMock()
        self.mockDataStore = DataStoreProtocolMock()
        self.mockProxyUtil = ProxyUtilProtocolMock()
        self.mockUserAgentUtil = UserAgentUtilProtocolMock()

        mockConfigurationRepository.getConfigurationHandler = {
            do {
                return try await MobileIdViewModelTests.defaultConfiguration()
            } catch {
                Issue.record("Unable to get configuration. \(error)")
                return nil
            }
        }
        mockDataStore.getRelyingPartyUUIDHandler = { Constants.Signing.RelyingPartyUUID }
        mockDataStore.getSelectedLanguageHandler = { "en" }
        mockDataStore.getIsRoleAndAddressEnabledHandler = { true }

        mockCertificatUtil.certificateHandler = { _ in
            SecCertificateCreateWithData(nil, Data() as CFData)
        }

        viewModel = MobileIdViewModel(
            configurationRepository: mockConfigurationRepository,
            mobileIdSignService: mockMobileIdSignService,
            certificateUtil: mockCertificatUtil,
            dataStore: mockDataStore,
            proxyUtil: mockProxyUtil,
            userAgentUtil: mockUserAgentUtil
        )
    }

    @Test
    func isRoleDataEnabled_successWithTrue() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = { true }

        let isRoleAndAddressEnabled = await viewModel.isRoleDataEnabled()

        #expect(isRoleAndAddressEnabled)
    }

    @Test
    func isRoleDataEnabled_successWithFalse() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = { false }

        let isRoleAndAddressEnabled = await viewModel.isRoleDataEnabled()

        #expect(!isRoleAndAddressEnabled)
    }

    @Test
    func saveInputData_successSavingValues() async {
        mockDataStore.setMobileIdInputDataHandler = { _ in }

        await viewModel.saveInputData(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            rememberMe: true
        )

        #expect(mockDataStore.setMobileIdInputDataCallCount == 1)
    }

    @Test
    func getInputData_returnSavedValues() async {
        let inputData = MobileIdInputData(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            rememberMe: false
        )

        mockDataStore.getMobileIdInputDataHandler = { inputData }

        let result = await viewModel.getInputData()

        #expect(result.phoneNumber == inputData.phoneNumber)
        #expect(result.personalCode == inputData.personalCode)
        #expect(result.rememberMe == inputData.rememberMe)
    }

    @Test
    func isSigningEnabled_returnTrueWithValidInput() {
        let isSigningEnabled = viewModel.isSigningEnabled(
            phoneNumber: "37251234567",
            personalCode: "60001019906"
        )

        #expect(isSigningEnabled)
    }

    @Test
    func isSigningEnabled_returnFalseWithInvalidPhoneNumber() {
        let isSigningEnabled = viewModel.isSigningEnabled(
            phoneNumber: "123",
            personalCode: "60001019906"
        )
        #expect(!isSigningEnabled)
    }

    @Test
    func isSigningEnabled_returnFalseWithInvalidPersonalCode() {
        let isSigningEnabled = viewModel.isSigningEnabled(
            phoneNumber: "37251234567",
            personalCode: "ABC"
        )
        #expect(!isSigningEnabled)
    }

    @Test
    func resetErrors_success() {
        viewModel.mobileIdMessageKey = "error"
        viewModel.showMobileIdAlertMessage = true
        viewModel.mobileIdAlertMessageExtraArguments = ["x"]
        viewModel.mobileIdAlertMessageUrl = "url"

        viewModel.resetErrors()

        #expect(viewModel.mobileIdMessageKey == nil)
        #expect(!viewModel.showMobileIdAlertMessage)
        #expect(viewModel.mobileIdAlertMessageExtraArguments.isEmpty)
        #expect(viewModel.mobileIdAlertMessageUrl == nil)
    }

    @Test
    func sign_returnSignedContainerSuccessfully() async {
        mockDataStore.getSelectedLanguageHandler = { "et" }

        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }
        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }
        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result != nil)
        #expect(viewModel.controlCode == "1234")
        #expect(viewModel.mobileIdMessageKey == "Signature added")
    }

    @Test
    func sign_returnNilWithMissingConfiguration() async {
        mockConfigurationRepository.getConfigurationHandler = { nil }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "General error")
    }

    @Test
    func sign_returnNilWithMissingContainerFile() async {
        let container = SignedContainerProtocolMock()
        container.getRawContainerFileHandler = { nil }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
    }

    @Test
    func sign_setGeneralErrorWhenCertificateRequestThrows() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.generalError
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "General error")
    }

    @Test
    func sign_setGeneralErrorWhenCertificateBase64Invalid() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse(cert: "!!!")
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
    }

    @Test
    func sign_returnNilWhenPrepareSignatureFails() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let container = mockContainer(
            prepareSignatureError: MobileIdError.generalError
        )

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
    }

    @Test
    func sign_returnNilWhenVerificationCodeNil() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in nil }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
    }

    @Test
    func sign_returnNilWhenMissingSessionId() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature(sessionId: nil)
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Signing technical error")
    }

    @Test
    func sign_returnNilWhenSessionWithoutSignature() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession(signature: nil)
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
    }

    @Test
    func sign_setTechnicalErrorWhenAddSignatureFails() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let digidocError = DigiDocError.signatureAddingFailed(
            ErrorDetail(message: "Failed to connect")
        )

        let container = mockContainer(addSignatureError: digidocError)

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "No Internet connection")
    }

    @Test
    func sign_setNotClientMessageWhenNotMidClientErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.notMidClient
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Not a mobile-id client")
    }

    @Test
    func sign_setExpiredTransactionMessageWhenTimeoutErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.timeout
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Expired mobile-ID transaction")
    }

    @Test
    func sign_setUserCancelledMessageWhenUserCancelledErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.userCancelled
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "User denied or cancelled")
    }

    @Test
    func sign_setAlertMessageWhenTooManyRequestsErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.tooManyRequests
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.showMobileIdAlertMessage == true)
        #expect(viewModel.mobileIdAlertMessageKey == "Too many requests")
        #expect(viewModel.mobileIdAlertMessageExtraArguments == ["Mobile-ID"])
    }

    @Test
    func sign_setAlertMessageWhenInvalidAccessRightsErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.invalidAccessRights
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.showMobileIdAlertMessage)
        #expect(viewModel.mobileIdAlertMessageKey == "Invalid signing access rights")
    }

    @Test
    func sign_doesNotSetErrorMessageWhenExplicitlyCancelledErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.explicitlyCancelled
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == nil)
    }

    @Test
    func sign_setSSLMessageWhenSslHandshakeFailureErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let error = DigiDocError.signatureAddingFailed(
            ErrorDetail(message: "Failed to create ssl connection with host")
        )

        let container = mockContainer(addSignatureError: error)

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "SSL handshake failed")
    }

    @Test
    func sign_setAlertWhenOcspErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let error = DigiDocError.signatureAddingFailed(
            ErrorDetail(message: "OCSP response not in valid time slot")
        )

        let container = mockContainer(addSignatureError: error)

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
        #expect(viewModel.showMobileIdAlertMessage)
        #expect(viewModel.mobileIdAlertMessageKey == "OCSP response not in valid time slot")
        #expect(viewModel.mobileIdAlertMessageUrl == "OCSP response not in valid time slot url")
    }

    @Test
    func sign_setRevokedMessageWhenRevokedCertificateErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let error = DigiDocError.signatureAddingFailed(
            ErrorDetail(message: "Certificate status: revoked")
        )

        let container = mockContainer(addSignatureError: error)

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Certificate status revoked")
    }

    @Test
    func sign_setProxyMessageWhenProxyAuthenticationErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let error = DigiDocError.signatureAddingFailed(
            ErrorDetail(message: "Failed to authenticate with proxy")
        )

        let container = mockContainer(addSignatureError: error)

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Invalid proxy settings")
    }

    @Test
    func sign_setTechnicalErrorWhenUnknownDigiDocErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockMobileIdCertificateResponse()
        }

        mockMobileIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockMobileIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockMobileIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let error = DigiDocError.signatureAddingFailed(
            ErrorDetail(message: "Something completely unknown")
        )

        let container = mockContainer(addSignatureError: error)

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Signing technical error")
    }

    @Test
    func sign_doesNotSetErrorMessageWhenCancellationErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw CancellationError()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == nil)
        #expect(viewModel.showMobileIdAlertMessage == false)
    }

    @Test
    func sign_setGeneralErrorWhenNonMobileIdErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw NSError(domain: "TestError", code: 1)
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "General error")
    }

    @Test
    func sign_setIncorrectParametersMessageWhenIncorrectParametersThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.incorrectParameters
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Mobile-ID incorrect parameters")
    }

    @Test
    func sign_setFailedTransactionMessageWhenSignatureHashMismatch() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.signatureHashMismatch
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Failed mobile-ID transaction")
    }

    @Test
    func sign_setCoverageMessageWhenPhoneAbsentErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.phoneAbsent
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Phone is not in coverage area")
    }

    @Test
    func sign_setRequestSendingErrorMessageWhenDeliveryErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.deliveryError
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "Request sending error")
    }

    @Test
    func sign_setSimErrorMessageWhenSimErrorThrown() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.simError
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "SIM error")
    }

    @Test
    func sign_setNoInternetMessageWhenNoInternetConnection() async {
        mockMobileIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw MobileIdError.noInternetConnection
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            phoneNumber: "37251234567",
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer()
        )

        #expect(result == nil)
        #expect(viewModel.mobileIdMessageKey == "No Internet connection")
    }

    private static func defaultConfiguration() throws -> ConfigurationProvider {
        try TestConfigurationProvider.mockConfigurationProvider()
    }

    private func mockContainer(
        prepareSignatureError: Error? = nil,
        addSignatureError: Error? = nil
    ) -> SignedContainerProtocolMock {
        let container = SignedContainerProtocolMock()

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/test.asice")
        }

        container.prepareSignatureHandler = { _, _, _, _ in
            if let error = prepareSignatureError {
                throw error
            }
            return Data([0x01])
        }

        container.addSignatureHandler = { _, _ in
            if let error = addSignatureError {
                throw error
            }
            return container
        }

        return container
    }

    private func mockMobileIdCertificateResponse(
        result: MobileIdCertificateResult? = .ok,
        cert: String? = Data([0x01]).base64EncodedString(),
        time: String? = Date.now.formatted(),
        traceId: String? = nil
    ) -> MobileIdCertificateResponse {
        return MobileIdCertificateResponse(
            result: result,
            cert: cert,
            time: time,
            traceId: traceId
        )
    }

    private func mockSuccessSignature(
        sessionId: String? = "session"
    ) -> MobileIdSignatureResponse {
        MobileIdSignatureResponse(sessionID: sessionId)
    }

    private func mockSuccessSession(
        state: SessionResponseState? = .complete,
        result: SessionResultCode? = .ok,
        signature: MobileIdSessionSignatureResponse? = MobileIdSessionSignatureResponse(
            value: Data([0x02]),
            algorithm: "TestAlgorithm"
        ),
        cert: String? = Data([0x01]).base64EncodedString(),
        time: String? = Date.now.formatted(),
        traceId: String? = nil
    ) -> MobileIdSessionResponse {
        MobileIdSessionResponse(
            state: state,
            result: result,
            signature: signature,
            cert: cert,
            time: time,
            traceId: traceId
        )
    }
}
