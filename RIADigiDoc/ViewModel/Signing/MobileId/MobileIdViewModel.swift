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
import OSLog
import Alamofire
import MobileIdLib
import LibdigidocLibSwift
import UtilsLib
import ConfigLib
import CommonsLib

@MainActor
class MobileIdViewModel: MobileIdViewModelProtocol, ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "MobileIdViewModel")

    private static let certificateEndpoint = "/certificate"
    private static let signatureEndpoint = "/signature"
    private static let signatureSessionEndpoint = "\(signatureEndpoint)/session"

    @Published var controlCode: String = "- - - -"

    @Published var countryCodeAndPhoneErrorKey: String?
    @Published var personalCodeErrorKey: String?

    @Published var mobileIdMessageKey: String?
    @Published var mobileIdAlertMessageKey: String?
    @Published var mobileIdAlertMessageExtraArguments: [String] = []
    @Published var showMobileIdAlertMessage: Bool = false
    @Published var mobileIdAlertMessageUrl: String?

    private let configurationRepository: ConfigurationRepositoryProtocol
    private let mobileIdSignService: MobileIdSignServiceProtocol
    private let certificateUtil: CertificateUtilProtocol
    private let dataStore: DataStoreProtocol

    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        mobileIdSignService: MobileIdSignServiceProtocol,
        certificateUtil: CertificateUtilProtocol,
        dataStore: DataStoreProtocol
    ) {
        self.configurationRepository = configurationRepository
        self.mobileIdSignService = mobileIdSignService
        self.certificateUtil = certificateUtil
        self.dataStore = dataStore
    }

    func isSigningEnabled(
        phoneNumber: String,
        personalCode: String
    ) -> Bool {
        checkPhoneNumberValidity(phoneNumber)
        checkPersonalCodeValidity(personalCode)
        return (!phoneNumber.isEmpty &&
                countryCodeAndPhoneErrorKey?.isEmpty == true) &&
        (!personalCode.isEmpty &&
         personalCodeErrorKey?.isEmpty == true)
    }

    func saveInputData(
        phoneNumber: String,
        personalCode: String,
        rememberMe: Bool
    ) async {
        await dataStore
            .setMobileIdInputData(
                MobileIdInputData(
                    phoneNumber: phoneNumber,
                    personalCode: personalCode,
                    rememberMe: rememberMe
                )
            )
    }

    func getInputData() async -> MobileIdInputData {
        return await dataStore.getMobileIdInputData()
    }

    func resetErrors() {
        mobileIdMessageKey = nil
        mobileIdAlertMessageKey = nil
        mobileIdAlertMessageExtraArguments = []
        showMobileIdAlertMessage = false
        mobileIdAlertMessageUrl = nil
    }

    func sign(
        phoneNumber: String,
        personalCode: String,
        signedContainer: SignedContainerProtocol
    ) async -> SignedContainerProtocol? {
        MobileIdViewModel.logger.debug("Mobile-ID: Signing with Mobile-ID")
        let currentConfiguration = await configurationRepository.getConfiguration()

        guard let configuration = currentConfiguration else {
            MobileIdViewModel.logger.error(
                "Mobile-ID: Unable to get configuration to sign with Mobile-ID"
            )
            mobileIdMessageKey = "General error"
            return nil
        }

        let savedUuid = await getUUID()
        let uuid = savedUuid.isEmpty ? Constants.Signing.RelyingPartyUUID : savedUuid
        let midUrl = (
            uuid.isEmpty || uuid == Constants.Signing.RelyingPartyUUID
        ) ? configuration.midRestUrl : configuration.midSkRestUrl
        let certBundle = configuration.certBundle

        let trustedCertificates = getTrustedCertificates(certificates: certBundle)

        let containerFile: URL
        do {
            containerFile = try await getContainerFile(signedContainer: signedContainer)
        } catch {
            MobileIdViewModel.logger.debug("Mobile-ID: Unable to get container file from container")
            handleSigningError(error)
            return nil
        }

        let cert: Data
        do {
            cert = try await requestCertificate(
                midUrl: midUrl,
                phoneNumber: phoneNumber,
                personalCode: personalCode,
                trustedCertificates: trustedCertificates
            )
        } catch {
            MobileIdViewModel.logger.debug("Mobile-ID: Unable to request certificate or get cert from response")
            handleSigningError(error)
            return nil
        }

        let hash: Data
        do {
            hash = try await prepareSignature(
                cert: cert,
                containerFile: containerFile,
                signedContainer: signedContainer
            )
        } catch {
            MobileIdViewModel.logger.debug("Mobile-ID: Unable to prepare signature for signing")
            handleSigningError(error)
            return nil
        }

        let verificationCode: String
        do {
            verificationCode = try await getVerificationCode(hash: hash)
        } catch {
            MobileIdViewModel.logger.debug("Mobile-ID: Unable to get verification code (control code)")
            handleSigningError(error)
            return nil
        }

        controlCode = verificationCode

        MobileIdViewModel.logger.debug("Mobile-ID: Getting language")
        let language = await dataStore.getSelectedLanguage()

        let sessionId: String
        do {
            sessionId = try await requestSignature(
                midUrl: midUrl,
                phoneNumber: phoneNumber,
                personalCode: personalCode,
                hash: hash,
                language: language,
                trustedCertificates: trustedCertificates
            )
        } catch {
            MobileIdViewModel.logger.debug("Mobile-ID: Unable to request signature")
            handleSigningError(error)
            return nil
        }

        let signatureData: Data
        do {
            signatureData = try await requestSession(
                midUrl: midUrl,
                sessionId: sessionId,
                trustedCertificates: trustedCertificates
            )
        } catch {
            MobileIdViewModel.logger.debug(
                "Mobile-ID: Unable to request session"
            )
            handleSigningError(error)
            return nil
        }

        do {
            try Task.checkCancellation()

            let updatedContainer = try await signedContainer.addSignature(
                signature: signatureData,
                containerFile: containerFile
            )

            MobileIdViewModel.logger.debug("Signature added successfully (Mobile-ID)")
            mobileIdMessageKey = "Signature added"
            return updatedContainer
        } catch {
            MobileIdViewModel.logger.error("Unable to sign container with Mobile-ID: \(error)")
            handleSignatureAddingError(error)
            return nil
        }
    }

    private func requestCertificate(
        midUrl: URL,
        phoneNumber: String,
        personalCode: String,
        trustedCertificates: [SecCertificate]
    ) async throws -> Data {
        MobileIdViewModel.logger.debug("Mobile-ID: Getting certificate")
        let certResponse = try await mobileIdSignService
            .getCertificateRequest(
                url: "\(midUrl)\(MobileIdViewModel.certificateEndpoint)",
                relyingPartyName: Constants.Signing.RelyingPartyName,
                relyingPartyUUID: Constants.Signing.RelyingPartyUUID,
                phoneNumber: phoneNumber,
                nationalIdentityNumber: personalCode,
                trustedCertificates: trustedCertificates
            )

        guard let certData = Data(
            base64Encoded: certResponse.cert ?? ""
        ) else {
            MobileIdViewModel.logger.error("Unable to get Mobile-ID certificate as data")
            mobileIdMessageKey = "General error"
            throw MobileIdError.generalError
        }

        return certData
    }

    // swiftlint:disable:next function_parameter_count
    private func requestSignature(
        midUrl: URL,
        phoneNumber: String,
        personalCode: String,
        hash: Data,
        language: String,
        trustedCertificates: [SecCertificate]
    ) async throws -> String {
        MobileIdViewModel.logger.debug("Mobile-ID: Getting signature")
        let signatureResponse = try await mobileIdSignService.getSignatureRequest(
            url: "\(midUrl)\(MobileIdViewModel.signatureEndpoint)",
            relyingPartyName: Constants.Signing.RelyingPartyName,
            relyingPartyUUID: Constants.Signing.RelyingPartyUUID,
            phoneNumber: phoneNumber,
            nationalIdentityNumber: personalCode,
            hash: hash,
            hashType: Constants.Signing.HashType,
            language: getThreeLetterLanguage(from: language),
            displayText: NSLocalizedString("Sign document", comment: ""),
            displayTextFormat: Constants.MobileId.DisplayTextFormat,
            trustedCertificates: trustedCertificates
        )

        MobileIdViewModel.logger.debug("Mobile-ID: Getting sessionID")
        guard let sessionId = signatureResponse.sessionID else {
            MobileIdViewModel.logger.error("Unable to get Mobile-ID sessionID")
            mobileIdMessageKey = "Technical error"
            throw MobileIdError.technicalError
        }

        return sessionId
    }

    private func requestSession(
        midUrl: URL,
        sessionId: String,
        trustedCertificates: [SecCertificate]
    ) async throws -> Data {
        MobileIdViewModel.logger.debug("Mobile-ID: Getting session request")
        let sessionResponse = try await mobileIdSignService.getSessionRequest(
            url: "\(midUrl)\(MobileIdViewModel.signatureSessionEndpoint)",
            sessionId: sessionId,
            pollingTimeout: Constants.Signing.DefaultTimeout,
            trustedCertificates: trustedCertificates
        )

        guard let signatureData = sessionResponse.signature?.value else {
            throw MobileIdError.technicalError
        }

        return signatureData
    }

    private func prepareSignature(
        cert: Data,
        containerFile: URL,
        signedContainer: SignedContainerProtocol
    ) async throws -> Data {
        MobileIdViewModel.logger.debug(
            "Mobile-ID: Preparing signature. Calculating hash"
        )

        return try await signedContainer.prepareSignature(
            cert: cert,
            containerPath: containerFile,
            roles: [],
            roleCity: "",
            roleState: "",
            roleCountry: "",
            roleZip: "",
            userAgent: ""
        )
    }

    private func getVerificationCode(hash: Data) async throws -> String {
        MobileIdViewModel.logger.debug(
            "Mobile-ID: Calculating verification code (control code)"
        )
        guard let verificationCode = await mobileIdSignService.getVerificationCode(hash: hash) else {
            MobileIdViewModel.logger.error("Unable to get Mobile-ID verification code")
            mobileIdMessageKey = "General error"
            throw MobileIdError.generalError
        }

        return verificationCode
    }

    private func getContainerFile(signedContainer: SignedContainerProtocol) async throws -> URL {
        guard let containerFile = await signedContainer.getRawContainerFile() else {
            MobileIdViewModel.logger.error(
                "Unable to sign with Mobile-ID. Unable to get container file"
            )
            mobileIdMessageKey = "General error"
            throw MobileIdError.generalError
        }

        return containerFile
    }

    private func getUUID() async -> String {
        return await dataStore.getRelyingPartyUUID()
    }

    private func getTrustedCertificates(certificates: [Data]) -> [SecCertificate] {
        MobileIdViewModel.logger.debug("Mobile-ID: Getting trusted certificates list")
        return certificates.compactMap { certificateUtil.certificate(from: $0) }
    }

    private func getThreeLetterLanguage(from language: String) -> String {
        return switch language {
        case "et": "EST"
        default: "ENG"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func handleSigningError(_ error: Error) {
        MobileIdViewModel.logger.error("Unable to sign container with Mobile-ID: \(error)")

        if let cancellationError = error as? CancellationError {
            MobileIdViewModel.logger.error("Mobile-ID signing manually cancelled: \(cancellationError)")
            // Do not throw an error if user cancelled signing with back button
            return
        }

        guard let mobileIdError = error as? MobileIdError else {
            mobileIdMessageKey = "General error"
            return
        }

        switch mobileIdError {
        case .notMidClient:
            mobileIdMessageKey = "Not a mobile-id client"

        case .generalError, .uninitializedSession:
            mobileIdMessageKey = "General error"

        case .explicitlyCancelled:
            // Do not throw an error if user cancelled signing with back button
            MobileIdViewModel.logger.debug("Mobile-ID signing manually cancelled")
            mobileIdMessageKey = nil

        case .timeout:
            mobileIdMessageKey = "Expired mobile-ID transaction"

        case .incorrectParameters:
            mobileIdMessageKey = "Signing incorrect parameters"

        case .userCancelled:
            mobileIdMessageKey = "User denied or cancelled"

        case .signatureHashMismatch:
            mobileIdMessageKey = "Failed mobile-ID transaction"

        case .phoneAbsent:
            mobileIdMessageKey = "Phone is not in coverage area"

        case .deliveryError:
            mobileIdMessageKey = "Request sending error"

        case .simError:
            mobileIdMessageKey = "SIM error"

        case .noInternetConnection:
            mobileIdMessageKey = "No Internet connection"

        case .tooManyRequests:
            showMobileIdAlertMessage = true
            mobileIdAlertMessageKey = "Too many requests"
            mobileIdAlertMessageUrl = "Too many requests url"
            mobileIdAlertMessageExtraArguments = ["Mobile-ID"]

        case .exceededUnsuccessfulRequests:
            mobileIdMessageKey = "Exceeded unsuccessful requests"

        case .invalidAccessRights:
            showMobileIdAlertMessage = true
            mobileIdAlertMessageKey = "Invalid signing access rights"
            mobileIdAlertMessageUrl = "Invalid signing access rights url"
            mobileIdAlertMessageExtraArguments = ["Mobile-ID"]

        case .technicalError:
            mobileIdMessageKey = "Signing technical error"
            mobileIdAlertMessageExtraArguments = ["Mobile-ID"]
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func handleSignatureAddingError(_ error: Error) {
        MobileIdViewModel.logger.error("Unable to sign container with Mobile-ID: \(error)")

        if let cancellationError = error as? CancellationError {
            MobileIdViewModel.logger.error("Mobile-ID signing manually cancelled: \(cancellationError)")
            return
        }

        guard let digidocError = error as? DigiDocError else {
            mobileIdMessageKey = "General error"
            return
        }

        switch digidocError {
        case .signatureAddingFailed(let errorDetail):
            let message = errorDetail.message

            let sslError = "Failed to create ssl connection with host"
            let tooManyRequestsError = "Too Many Requests"
            let ocspError = "OCSP response not in valid time slot"
            let revokedCertError = "Certificate status: revoked"
            let connectError = "CONNECT: 403"
            let failedToConnectError = "Failed to connect"
            let proxyError = "Failed to authenticate with proxy"

            switch true {
            case message.contains(sslError):
                mobileIdMessageKey = "SSL handshake failed"

            case message.contains(tooManyRequestsError):
                showMobileIdAlertMessage = true
                mobileIdAlertMessageKey = "Too many requests"
                mobileIdAlertMessageUrl = "Too many requests url"
                mobileIdAlertMessageExtraArguments = ["Mobile-ID"]

            case message.contains(ocspError):
                showMobileIdAlertMessage = true
                mobileIdAlertMessageKey = "OCSP response not in valid time slot"
                mobileIdAlertMessageUrl = "OCSP response not in valid time slot url"

            case message.contains(revokedCertError):
                mobileIdMessageKey = "Certificate status revoked"

            case message.contains(connectError), message.contains(failedToConnectError):
                mobileIdMessageKey = "No Internet connection"

            case message.contains(proxyError):
                mobileIdMessageKey = "Invalid proxy settings"

            default:
                mobileIdMessageKey = "Signing technical error"
                mobileIdAlertMessageExtraArguments = ["Mobile-ID"]
            }

        default:
            mobileIdMessageKey = "General error"
        }
    }

    private func checkPhoneNumberValidity(_ phoneNumber: String) {
        switch true {
        case PhoneNumberValidator.isCountryCodeMissing(phoneNumber):
            countryCodeAndPhoneErrorKey = "Country code not included"
        case !PhoneNumberValidator.isCountryCodeCorrect(phoneNumber):
            countryCodeAndPhoneErrorKey = "Invalid country code"
        case !PhoneNumberValidator.isPhoneNumberCorrect(phoneNumber):
            countryCodeAndPhoneErrorKey = "Invalid phone number"
        default:
            countryCodeAndPhoneErrorKey = ""
        }
    }

    private func checkPersonalCodeValidity(_ personalCode: String) {
        guard personalCode.isEmpty || PersonalCodeValidator.isPersonalCodeValid(personalCode) else {
            personalCodeErrorKey = "Invalid personal code"
            return
        }
        personalCodeErrorKey = ""
    }
}
