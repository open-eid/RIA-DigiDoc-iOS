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
import CommonsLib
import IdCardLib
import LibdigidocLibSwift
import LibdigidocLibSwiftMocks
import UtilsLibMocks

@MainActor
final class IdCardViewModelTests {

    private let mockRepository: IdCardRepositoryProtocolMock
    private let mockSession: SharedMyEidSessionProtocolMock
    private let mockCertificateUtil: CertificateUtilProtocolMock
    private let mockNameUtil: NameUtilProtocolMock
    private let mockDataStore: DataStoreProtocolMock
    private let mockUserAgentUtil: UserAgentUtilProtocolMock
    private let viewModel: IdCardViewModel

    init() async throws {
        mockRepository = IdCardRepositoryProtocolMock()
        mockSession = SharedMyEidSessionProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()
        mockNameUtil = NameUtilProtocolMock()
        mockDataStore = DataStoreProtocolMock()
        mockUserAgentUtil = UserAgentUtilProtocolMock()

        viewModel = IdCardViewModel(
            idCardRepository: mockRepository,
            sharedMyEidSession: mockSession,
            certificateUtil: mockCertificateUtil,
            nameUtil: mockNameUtil,
            dataStore: mockDataStore,
            userAgentUtil: mockUserAgentUtil
        )
    }

    @Test
    func sign_success() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: ["Role"], city: "City", state: "State", country: "EE", zipCode: "12345")

        let expectedSignature = Data([0x01])
        let expectedFinalContainer = SignedContainerProtocolMock()

        mockSignedContainer.getRawContainerFileHandler = {
            URL(fileURLWithPath: "/tmp/test.asice")
        }

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data([0xAA]) }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in
            Data([0xBB])
        }

        mockRepository.calculateSignatureHandler = { _, _ in
            expectedSignature
        }

        mockSignedContainer.addSignatureHandler = { _, _ in
            expectedFinalContainer
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: roleData
        )

        #expect(result as? SignedContainerProtocolMock === expectedFinalContainer)
    }

    @Test
    func sign_returnNilWhenRetryCountZero() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in (0, true) }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
    }

    @Test
    func sign_returnNilWhenPinLocked() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, false) }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
    }

    @Test
    func sign_returnNilWhenPrepareSignatureThrowsError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data([0xAA]) }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in
            throw NSError(domain: "Test", code: 1)
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
    }

    @Test
    func sign_returnNilWhenCalculateSignatureThrows() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data([0xAA]) }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in
            Data([0xBB])
        }

        mockRepository.calculateSignatureHandler = { _, _ in
            throw IdCardInternalError.connectionFailed
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
    }

    @Test
    func sign_returnNilWhenReadCodeTryCounterRecordThrowsError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in
            throw IdCardInternalError.connectionFailed
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
    }

    @Test
    func sign_setShouldDismissWhenCancelledByUser() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in
            throw IdCardError.cancelledByUser
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.shouldDismissForError)
    }

    @Test
    func sign_showAlertWhenPinLocked() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in
            throw IdCardError.pinLocked
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
        #expect(viewModel.showIdCardAlertMessage)
        #expect(viewModel.idCardAlertMessageKey == "PIN2 locked")
        #expect(viewModel.idCardAlertMessageUrl == "PIN2 locked URL")
    }

    @Test
    func sign_setErrorMessageWhenWrongPinMultipleTriesLeft() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in
            throw IdCardError.wrongPIN(triesLeft: 2)
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
        #expect(viewModel.errorMessage == "PIN verification error multiple")
        #expect(viewModel.errorExtraArguments == ["PIN2", "2"])
    }

    @Test
    func sign_setErrorMessageWhenWrongPinOneTryLeft() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in
            throw IdCardError.wrongPIN(triesLeft: 1)
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
        #expect(viewModel.errorMessage == "PIN verification error one")
        #expect(viewModel.errorExtraArguments == ["PIN2"])
    }

    @Test
    func sign_showAlertWhenWrongPinNoTriesLeft() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in
            throw IdCardError.wrongPIN(triesLeft: 0)
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
        #expect(viewModel.showIdCardAlertMessage)
        #expect(viewModel.idCardAlertMessageKey == "PIN blocked")
        #expect(viewModel.idCardAlertMessageExtraArguments == ["PIN2"])
    }

    @Test
    func sign_setGeneralErrorAndDismissWhenSessionError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()

        mockRepository.readCodeTryCounterRecordHandler = { _ in
            throw IdCardError.sessionError
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: .init(roles: [], city: "", state: "", country: "", zipCode: "")
        )

        #expect(result == nil)
        #expect(viewModel.errorMessage == "General error")
        #expect(viewModel.shouldDismissForError)
    }

    @Test
    func sign_setSslErrorMessageWhenSignatureAddingFailsWithSslError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "Failed to create ssl connection with host")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(
            pin2: "12345",
            signedContainer: mockSignedContainer,
            roleData: roleData
        )

        #expect(result == nil)
        #expect(viewModel.errorMessage == "SSL handshake failed")
    }

    @Test
    func sign_dontSetErrorWhenSignatureAddingCancelled() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        mockSignedContainer.addSignatureHandler = { _, _ in
            throw CancellationError()
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.showIdCardAlertMessage)
    }

    @Test
    func sign_setGeneralErrorWhenSignatureAddingThrowsNonDigiDocError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        mockSignedContainer.addSignatureHandler = { _, _ in
            throw NSError(domain: "Test", code: 1)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.errorMessage == "General error")
    }

    @Test
    func sign_showAlertWhenSignatureAddingFailsWithTooManyRequestsError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "Too Many Requests")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.showIdCardAlertMessage)
        #expect(viewModel.idCardAlertMessageKey == "Too many requests")
        #expect(viewModel.idCardAlertMessageUrl == "Too many requests url")
        #expect(viewModel.idCardAlertMessageExtraArguments == ["ID card conditional speech"])
    }

    @Test
    func sign_showAlertWhenSignatureAddingFailsWithOcspError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "OCSP response not in valid time slot")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.showIdCardAlertMessage)
        #expect(viewModel.idCardAlertMessageKey == "OCSP response not in valid time slot")
        #expect(viewModel.idCardAlertMessageUrl == "OCSP response not in valid time slot url")
    }

    @Test
    func sign_setErrorMessageWhenSignatureAddingFailsWithRevokedCertificateError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "Certificate status: revoked")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.errorMessage == "Certificate status revoked")
    }

    @Test
    func sign_setErrorMessageWhenSignatureAddingFailsWithConnect403Error() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "CONNECT: 403")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.errorMessage == "No Internet connection")
    }

    @Test
    func sign_setErrorMessageWhenSignatureAddingFailsWithFailedToConnectError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "Failed to connect")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.errorMessage == "No Internet connection")
    }

    @Test
    func sign_setErrorMessageWhenSignatureAddingFailsWithProxyError() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "Failed to authenticate with proxy")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.errorMessage == "Invalid proxy settings")
    }

    @Test
    func sign_setSigningTechnicalErrorWhenSignatureAddingFailsWithUnknownMessage() async throws {
        let mockSignedContainer = SignedContainerProtocolMock()
        let roleData = RoleData(roles: [], city: "", state: "", country: "", zipCode: "")

        mockRepository.readCodeTryCounterRecordHandler = { _ in (3, true) }
        mockRepository.readSignatureCertificateHandler = { Data() }
        mockDataStore.getSelectedLanguageHandler = { "et" }
        mockUserAgentUtil.userAgentHandler = { _, _ in "TestUserAgent" }

        mockSignedContainer.getRawContainerFileHandler = { URL(fileURLWithPath: "/tmp/test") }
        mockSignedContainer.prepareSignatureHandler = { _, _, _, _ in Data() }
        mockRepository.calculateSignatureHandler = { _, _ in Data() }

        let errorDetail = ErrorDetail(message: "Unknown signing failure")
        mockSignedContainer.addSignatureHandler = { _, _ in
            throw DigiDocError.signatureAddingFailed(errorDetail)
        }

        let result = await viewModel.sign(pin2: "12345", signedContainer: mockSignedContainer, roleData: roleData)

        #expect(result == nil)
        #expect(viewModel.errorMessage == "Signing technical error")
        #expect(viewModel.errorExtraArguments == ["ID card conditional speech"])
    }
}
