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
import Testing
import ConfigLibMocks
import SmartIdLib
import SmartIdLibMocks
import UtilsLibMocks
import CommonsLib
import LibdigidocLibSwift
import LibdigidocLibSwiftMocks

@MainActor
struct SmartIdViewModelTests {

    private let roleData = RoleData(
        roles: ["Role 1", "Role 2"],
        city: "Test City",
        state: "Test State",
        country: "Test Country",
        zipCode: "Test zip code"
    )

    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock
    private let mockSmartIdSignService: SmartIdSignServiceProtocolMock
    private let mockCertificatUtil: CertificateUtilProtocolMock
    private let mockNotificationUtil: NotificationUtilProtocolMock
    private let mockDataStore: DataStoreProtocolMock
    private let mockProxyUtil: ProxyUtilProtocolMock
    private let mockUserAgentUtil: UserAgentUtilProtocolMock

    private let viewModel: SmartIdViewModel

    init() async throws {
        self.mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        self.mockSmartIdSignService = SmartIdSignServiceProtocolMock()
        self.mockCertificatUtil = CertificateUtilProtocolMock()
        self.mockNotificationUtil = NotificationUtilProtocolMock()
        self.mockDataStore = DataStoreProtocolMock()
        self.mockProxyUtil = ProxyUtilProtocolMock()
        self.mockUserAgentUtil = UserAgentUtilProtocolMock()

        viewModel = SmartIdViewModel(
            configurationRepository: mockConfigurationRepository,
            smartIdSignService: mockSmartIdSignService,
            certificateUtil: mockCertificatUtil,
            notificationUtil: mockNotificationUtil,
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
    func isSigningEnabled_returnTrueWithValidPersonalCode() {
        let result = viewModel.isSigningEnabled(personalCode: "60001019906")

        #expect(result == true)
        #expect(viewModel.personalCodeErrorKey == "")
    }

    @Test
    func isSigningEnabled_returnFalseAndSetsErrorWithInvalidPersonalCode() {
        let result = viewModel.isSigningEnabled(personalCode: "invalid")

        #expect(result == false)
        #expect(viewModel.personalCodeErrorKey == "Invalid personal code")
    }

    @Test
    func isSigningEnabled_returnFalseWithoutErrorWithEmptyPersonalCode() {
        let result = viewModel.isSigningEnabled(personalCode: "")

        #expect(result == false)
        #expect(viewModel.personalCodeErrorKey == "")
    }

    @Test
    func saveInputData_returnSavedValuesSuccessfully() async {
        let expected = SmartIdInputData(
            country: .estonia,
            personalCode: "60001019906",
            rememberMe: true
        )

        mockDataStore.getSmartIdInputDataHandler = { expected }

        await viewModel.saveInputData(
            country: .estonia,
            personalCode: "60001019906",
            rememberMe: true
        )

        let result = await viewModel.getInputData()

        #expect(result.country == expected.country)
        #expect(result.personalCode == expected.personalCode)
        #expect(result.rememberMe == expected.rememberMe)
    }

    @Test
    func resetErrors_clearsAllErrorStates() {
        viewModel.smartIdErrorMessageKey = "Error"
        viewModel.smartIdAlertMessageKey = "Alert"
        viewModel.smartIdAlertMessageExtraArguments = ["Smart-ID"]
        viewModel.showSmartIdAlertMessage = true
        viewModel.smartIdAlertMessageUrl = "https://test.url"

        viewModel.resetErrors()

        #expect(viewModel.smartIdErrorMessageKey == nil)
        #expect(viewModel.smartIdAlertMessageKey == nil)
        #expect(viewModel.smartIdAlertMessageExtraArguments.isEmpty)
        #expect(viewModel.showSmartIdAlertMessage == false)
        #expect(viewModel.smartIdAlertMessageUrl == nil)
    }

    @Test
    func sign_returnNilAndSetGeneralErrorWhenConfigurationMissing() async {
        mockConfigurationRepository.getConfigurationHandler = nil

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let container = SignedContainerProtocolMock()

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
    }

    @Test
    func sign_returnNilAndSetGeneralErrorWhenContainerFileNil() async {
        let container = SignedContainerProtocolMock()
        container.getRawContainerFileHandler = nil

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
    }

    @Test
    func sign_setGeneralErrorWhenCertificateRequestThrowsGenericError() async {
        let container = SignedContainerProtocolMock()
        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw NSError(
                domain: "test",
                code: 1
            )
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
    }

    @Test
    func sign_returnNilWhenCertificateResponseMissingSessionId() async {
        let container = SignedContainerProtocolMock()
        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature(sessionId: nil)
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .lithuania,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
    }

    @Test
    func sign_setGeneralErrorWhenPrepareSignatureThrowsError() async {
        let container = SignedContainerProtocolMock()

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        container.prepareSignatureHandler = { _, _, _, _ in
            throw NSError(domain: "hash", code: 0)
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "38501010001",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
    }

    @Test
    func sign_signingSucceedsWhenNotificationPermissionDeniedAndNoNotificationShown() async {
        let container = SignedContainerProtocolMock()
        let verificationCode = "9999"

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        container.prepareSignatureHandler = { _, _, _, _ in
            Data("hash".utf8)
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in verificationCode }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockNotificationUtil.requestAuthorizationHandler = { false }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "38501010001",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result != nil)
        #expect(viewModel.controlCode == verificationCode)
        #expect(mockNotificationUtil.sendNotificationCallCount == 0)
    }

    @Test
    func sign_notificationSendThrowsErrorButDoesNotFailSigningFlow() async {
        let container = SignedContainerProtocolMock()
        let verificationCode = "1111"

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        container.prepareSignatureHandler = { _, _, _, _ in
            Data("hash".utf8)
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in verificationCode }

        mockNotificationUtil.requestAuthorizationHandler = { true }
        mockNotificationUtil.sendNotificationHandler = { _, _ in
            throw NSError(
                domain: "notification",
                code: 0
            )
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .latvia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result != nil)
        #expect(viewModel.controlCode == verificationCode)
    }

    @Test
    func sign_returnNilWhenCertificateResponseWithMissingCertValue() async {
        let container = SignedContainerProtocolMock()
        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession(cert: nil)
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == nil)
        #expect(viewModel.showSmartIdAlertMessage == false)
    }

    @Test
    func sign_returnNilWhenCertificateResponseWithMissingDocumentNumber() async {
        let container = SignedContainerProtocolMock()
        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession(
                result: SessionResult(
                    endResult: .documentUnusable,
                    documentNumber: nil
                )
            )
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .latvia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == nil)
        #expect(viewModel.showSmartIdAlertMessage == false)
    }

    @Test
    func sign_returnNilWhenAddSignatureThrowsSignatureAddingFailedError() async {
        let container = SignedContainerProtocolMock()

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        container.prepareSignatureHandler = { _, _, _, _ in
            Data("hash".utf8)
        }

        container.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(
                ErrorDetail(message: "Unable to add signature")
            )
        }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockNotificationUtil.requestAuthorizationHandler = { true }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "Signing technical error")
        #expect(viewModel.showSmartIdAlertMessage == false)
        #expect(mockNotificationUtil.removeNotificationCallCount == 1)
    }

    @Test
    func sign_returnNilWhenRequestSignatureThrowsTechnicalError() async {
        let container = SignedContainerProtocolMock()

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            throw SmartIdError.technicalError
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockNotificationUtil.requestAuthorizationHandler = { true }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "Signing technical error")
        #expect(viewModel.showSmartIdAlertMessage == false)
        #expect(mockNotificationUtil.removeNotificationCallCount == 1)
    }

    @Test
    func sign_returnNilWhenSessionIdMissing() async {
        let container = SignedContainerProtocolMock()

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature(sessionId: nil)
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockNotificationUtil.requestAuthorizationHandler = { true }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
        #expect(viewModel.showSmartIdAlertMessage == false)
    }

    @Test
    func sign_returnNilWhenSignatureMissing() async {
        let container = SignedContainerProtocolMock()

        container.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession(signature: nil)
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in "1234" }

        mockNotificationUtil.requestAuthorizationHandler = { true }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: container,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "Signing technical error")
        #expect(viewModel.showSmartIdAlertMessage == false)
    }

    @Test
    func sign_returnNilAndSetGeneralErrorWhenErrorIsNotSmartIdError() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw NSError(domain: "test", code: 0)
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
    }

    @Test
    func sign_doesNotSetErrorMessageWhenCancellationErrorThrown() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw CancellationError()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == nil)
    }

    @Test(
        "sign_setGeneralErrorWhenGeneralSmartIdErrorsThrown",
        arguments: [
            SmartIdError.generalError,
            .uninitializedSession,
            .missingSessionId
        ]
    )
    func sign_setGeneralErrorWhenGeneralSmartIdErrorsThrown(error: SmartIdError) async {

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw error
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
    }

    @Test
    func sign_doesNotSetErrorMessageWhenExplicitlyCancelledErrorThrown() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw SmartIdError.explicitlyCancelled
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == nil)
    }

    @Test(
        "sign_setNoInternetMessageWhenNoInternetConnectionErrorsThrown",
        arguments: [
            SmartIdError.noInternetConnection,
            .noResponse,
            .requestInterrupted
        ]
    )
    func sign_setNoInternetMessageWhenNoInternetConnectionErrorsThrown(
        error: SmartIdError
    ) async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw error
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "No Internet connection")
    }

    @Test
    func sign_doesNotSetErrorMessageWhenAttemptWasAlreadyCancelled() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw SmartIdError.timeout
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let viewModel = self.viewModel
        let roleData = self.roleData
        let container = mockContainer()

        let task = Task { @MainActor in
            await viewModel.sign(
                country: .estonia,
                personalCode: "60001019906",
                roleData: roleData,
                signedContainer: container,
                liveActivityTexts: SmartIdLiveActivityTexts(
                    initialMessage: "Initial message",
                    controlCodeTitle: "Control code",
                    compactTitle: "Code"
                )
            )
        }
        task.cancel()

        let result = await task.value

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == nil)
    }

    @Test
    func sign_setInvalidSigningAccessRightsWhenIncorrectParametersErrorThrown() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw SmartIdError.incorrectParameters
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "Invalid signing access rights")
    }

    @Test(
        "sign_setExpiredTransactionWhenTimeoutAndAccountNotFoundErrorsThrown",
        arguments: [SmartIdError.timeout, .accountNotFound]
    )
    func sign_setExpiredTransactionWhenTimeoutAndAccountNotFoundErrorsThrown(
        error: SmartIdError
    ) async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw error
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "Expired Smart-ID transaction")
    }

    @Test(
        "sign_setExpectedMessagesWithDifferentSmartIdErrors",
        arguments: [
            (SmartIdError.documentUnusable, "Failed Smart-ID transaction"),
            (.wrongVC, "Smart-ID wrong vc"),
            (.userRefused, "User denied or cancelled"),
            (.sessionNotFound, "Smart-ID session not found"),
            (.exceededUnsuccessfulRequests, "Exceeded unsuccessful requests"),
            (.notQualified, "Smart-ID certificate level not qualified"),
            (.oldApi, "Smart-ID old api"),
            (.underMaintenance, "Smart-ID under maintenance"),
            (.invalidSslHandshake, "SSL handshake failed"),
            (.certificateRevoked, "Certificate status revoked")
        ]
    )
    func sign_setExpectedMessagesWithDifferentSmartIdErrors(
        error: SmartIdError,
        expectedMessage: String
    ) async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw error
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == expectedMessage)

        viewModel.resetErrors()
    }

    @Test
    func sign_setAlertMessageWhenTooManyRequestsErrorThrown() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw SmartIdError.tooManyRequests
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.showSmartIdAlertMessage == true)
        #expect(viewModel.smartIdAlertMessageKey == "Too many requests")
        #expect(viewModel.smartIdAlertMessageExtraArguments == ["Smart-ID"])
    }

    @Test
    func sign_setAlertMessageWhenInvalidAccessRightsErrorThrown() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw SmartIdError.invalidAccessRights
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.showSmartIdAlertMessage == true)
        #expect(viewModel.smartIdAlertMessageKey == "Invalid signing access rights")
    }

    @Test
    func sign_setAlertMessageWhenOcspInvalidTimeSlotErrorThrown() async {
        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            throw SmartIdError.ocspInvalidTimeSlot
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer(),
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.showSmartIdAlertMessage == true)
        #expect(viewModel.smartIdAlertMessageKey == "OCSP response not in valid time slot")
    }

    @Test
    func sign_setGeneralErrorWhenAddSignatureThrowsNonDigiDocError() async {
        let mockContainer = mockContainer(
            addSignatureError: NSError(domain: "test", code: 0)
        )

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        mockContainer.prepareSignatureHandler = { _, _, _, _ in
            Data("hash".utf8)
        }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockNotificationUtil.requestAuthorizationHandler = { true }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == "General error")
    }

    @Test
    func sign_doesNotSetErrorMessageWhenAddSignatureThrowsCancellationError() async {
        let mockContainer = mockContainer(
            addSignatureError: CancellationError()
        )

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        mockContainer.prepareSignatureHandler = { _, _, _, _ in
            Data("hash".utf8)
        }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockNotificationUtil.requestAuthorizationHandler = { true }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        #expect(viewModel.smartIdErrorMessageKey == nil)
    }

    @Test(
        "sign_setExpectedMessagesWhenSignatureAddingFailedErrorsThrown",
        arguments: [
            ("Failed to create ssl connection with host", "SSL handshake failed", false, []),
            ("Too Many Requests", "Too many requests", true, ["Smart-ID"]),
            ("OCSP response not in valid time slot", "OCSP response not in valid time slot", true, []),
            ("Certificate status: revoked", "Certificate status revoked", false, []),
            ("CONNECT: 403", "No Internet connection", false, []),
            ("Failed to connect", "No Internet connection", false, []),
            ("Failed to authenticate with proxy", "Invalid proxy settings", false, []),
            ("Random error message", "Signing technical error", false, ["Smart-ID"])
        ]
    )
    func sign_setExpectedMessagesWhenSignatureAddingFailedErrorsThrown(
        errorMessage: String,
        expectedMessage: String,
        expectsAlert: Bool,
        extraArg: [String]
    ) async {
        let digidocError = DigiDocError.signatureAddingFailed(
            ErrorDetail(message: errorMessage)
        )
        let mockContainer = mockContainer(
            addSignatureError: digidocError
        )

        mockContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/container")
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        mockSmartIdSignService.getCertificateRequestHandler = { _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSignatureRequestHandler = { _, _, _, _, _, _, _, _, _, _, _ in
            await mockSuccessSignature()
        }

        mockSmartIdSignService.getSessionRequestHandler = { _, _, _, _, _, _ in
            await mockSuccessSession()
        }

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        mockContainer.prepareSignatureHandler = { _, _, _, _ in
            Data("hash".utf8)
        }

        mockSmartIdSignService.getVerificationCodeHandler = { _ in "1234" }
        mockNotificationUtil.requestAuthorizationHandler = { true }

        let result = await viewModel.sign(
            country: .estonia,
            personalCode: "60001019906",
            roleData: roleData,
            signedContainer: mockContainer,
            liveActivityTexts: SmartIdLiveActivityTexts(
                initialMessage: "Initial message",
                controlCodeTitle: "Control code",
                compactTitle: "Code"
            )
        )

        #expect(result == nil)
        if expectsAlert {
            #expect(viewModel.smartIdAlertMessageKey == expectedMessage)
            #expect(viewModel.smartIdAlertMessageExtraArguments.contains(extraArg))
        } else {
            #expect(viewModel.smartIdErrorMessageKey == expectedMessage)
        }

        viewModel.resetErrors()
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

    private func mockSuccessSignature(
        sessionId: String? = "session"
    ) -> SmartIdSessionIdResponse {
        SmartIdSessionIdResponse(sessionID: sessionId)
    }

    private func mockSuccessSession(
        state: SessionResponseState = .complete,
        result: SessionResult? = .init(
            endResult: .ok,
            documentNumber: "TestDocumentNumber"
        ),
        signature: SmartIdSessionSignatureResponse? = .init(
            value: Data([1, 2, 3]),
            algorithm: "TestAlgorithm"
        ),
        cert: SmartIdSessionCertResponse? = SmartIdSessionCertResponse(
            value: Data([1, 2, 3]),
            certificateLevel: .ADVANCED
        )
    ) -> SmartIdSessionResponse {
        SmartIdSessionResponse(
            state: state,
            result: result,
            signature: signature,
            cert: cert
        )
    }
}
