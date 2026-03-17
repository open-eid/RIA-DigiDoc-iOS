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
import Alamofire
import MobileIdLib
import LibdigidocLibSwift
import UtilsLib
import ConfigLib
import CommonsLib

@Observable
@MainActor
class MobileIdViewModel: MobileIdViewModelProtocol, Loggable {

    private static let certificateEndpoint = "/certificate"
    private static let signatureEndpoint = "/signature"
    private static let signatureSessionEndpoint = "\(signatureEndpoint)/session"

    var controlCode: String = "- - - -"
    var infoMessage: String = "Mobile-ID signing info message"

    var countryCodeAndPhoneErrorKey: String?
    var personalCodeErrorKey: String?

    var mobileIdSuccessMessageKey: String?
    var mobileIdErrorMessageKey: String?
    var mobileIdAlertMessageKey: String?
    var mobileIdAlertMessageExtraArguments: [String] = []
    var showMobileIdAlertMessage: Bool = false
    var mobileIdAlertMessageUrl: String?

    private let configurationRepository: ConfigurationRepositoryProtocol
    private let mobileIdSignService: MobileIdSignServiceProtocol
    private let certificateUtil: CertificateUtilProtocol
    private let dataStore: DataStoreProtocol
    private let proxyUtil: ProxyUtilProtocol
    private let userAgentUtil: UserAgentUtilProtocol

    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        mobileIdSignService: MobileIdSignServiceProtocol,
        certificateUtil: CertificateUtilProtocol,
        dataStore: DataStoreProtocol,
        proxyUtil: ProxyUtilProtocol,
        userAgentUtil: UserAgentUtilProtocol
    ) {
        self.configurationRepository = configurationRepository
        self.mobileIdSignService = mobileIdSignService
        self.certificateUtil = certificateUtil
        self.dataStore = dataStore
        self.proxyUtil = proxyUtil
        self.userAgentUtil = userAgentUtil
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
        mobileIdErrorMessageKey = nil
        mobileIdAlertMessageKey = nil
        mobileIdAlertMessageExtraArguments = []
        showMobileIdAlertMessage = false
        mobileIdAlertMessageUrl = nil
    }

    func sign(
        phoneNumber: String,
        personalCode: String,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol
    ) async -> SignedContainerProtocol? {
        MobileIdViewModel.logger().info("Mobile-ID: Signing with Mobile-ID")
        let currentConfiguration = await configurationRepository.getConfiguration()

        guard let configuration = currentConfiguration else {
            MobileIdViewModel.logger().error(
                "Mobile-ID: Unable to get configuration to sign with Mobile-ID"
            )
            mobileIdErrorMessageKey = "General error"
            return nil
        }

        let savedUuid = await getUUID()
        let uuid = savedUuid.isEmpty ? Constants.Signing.RelyingPartyUUID : savedUuid
        let midUrl = (
            uuid.isEmpty || uuid == Constants.Signing.RelyingPartyUUID
        ) ? configuration.midRestUrl : configuration.midSkRestUrl
        let certBundle = configuration.certBundle

        let trustedCertificates = getTrustedCertificates(certificates: certBundle)

        let proxyInfo = await proxyUtil.getProxyInfo()

        MobileIdViewModel.logger().info("Mobile-ID: Getting language")
        let appLanguage = await dataStore.getSelectedLanguage()

        MobileIdViewModel.logger().info("Mobile-ID: Getting User-Agent")
        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: appLanguage)

        let containerFile: URL
        do {
            containerFile = try await getContainerFile(signedContainer: signedContainer)
        } catch {
            MobileIdViewModel.logger().info("Mobile-ID: Unable to get container file from container")
            handleSigningError(error)
            return nil
        }

        let cert: Data
        do {
            cert = try await requestCertificate(
                midUrl: midUrl,
                phoneNumber: phoneNumber,
                personalCode: personalCode,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )
        } catch {
            MobileIdViewModel.logger().info("Mobile-ID: Unable to request certificate or get cert from response")
            handleSigningError(error)
            return nil
        }

        let hash: Data
        do {
            hash = try await prepareSignature(
                cert: cert,
                containerFile: containerFile,
                roleData: roleData,
                signedContainer: signedContainer,
                userAgent: userAgent
            )
        } catch {
            MobileIdViewModel.logger().info("Mobile-ID: Unable to prepare signature for signing")
            handleSigningError(error)
            return nil
        }

        let verificationCode: String
        do {
            verificationCode = try await getVerificationCode(hash: hash)
        } catch {
            MobileIdViewModel.logger().info("Mobile-ID: Unable to get verification code (control code)")
            handleSigningError(error)
            return nil
        }

        controlCode = verificationCode

        let sessionId: String
        do {
            sessionId = try await requestSignature(
                midUrl: midUrl,
                phoneNumber: phoneNumber,
                personalCode: personalCode,
                hash: hash,
                language: appLanguage,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )
        } catch {
            MobileIdViewModel.logger().info("Mobile-ID: Unable to request signature")
            handleSigningError(error)
            return nil
        }

        let signatureData: Data
        do {
            signatureData = try await requestSession(
                midUrl: midUrl,
                sessionId: sessionId,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )
        } catch {
            MobileIdViewModel.logger().info(
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

            MobileIdViewModel.logger().info("Signature added successfully (Mobile-ID)")
            mobileIdSuccessMessageKey = "Signature added"
            return updatedContainer
        } catch {
            MobileIdViewModel.logger().error("Unable to sign container with Mobile-ID: \(error)")
            handleSignatureAddingError(error)
            return nil
        }
    }

    func isRoleDataEnabled() async -> Bool {
        await dataStore.getIsRoleAndAddressEnabled()
    }

    // swiftlint:disable:next function_parameter_count
    private func requestCertificate(
        midUrl: URL,
        phoneNumber: String,
        personalCode: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> Data {
        MobileIdViewModel.logger().info("Mobile-ID: Getting certificate")
        let certResponse = try await mobileIdSignService
            .getCertificateRequest(
                url: "\(midUrl)\(MobileIdViewModel.certificateEndpoint)",
                relyingPartyName: Constants.Signing.RelyingPartyName,
                relyingPartyUUID: Constants.Signing.RelyingPartyUUID,
                phoneNumber: phoneNumber,
                nationalIdentityNumber: personalCode,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )

        guard let certData = Data(
            base64Encoded: certResponse.cert ?? ""
        ) else {
            MobileIdViewModel.logger().error("Unable to get Mobile-ID certificate as data")
            mobileIdErrorMessageKey = "General error"
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
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String {
        MobileIdViewModel.logger().info("Mobile-ID: Getting signature")
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
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )

        MobileIdViewModel.logger().info("Mobile-ID: Getting sessionID")
        guard let sessionId = signatureResponse.sessionID else {
            MobileIdViewModel.logger().error("Unable to get Mobile-ID sessionID")
            mobileIdErrorMessageKey = "Technical error"
            throw MobileIdError.technicalError
        }

        return sessionId
    }

    private func requestSession(
        midUrl: URL,
        sessionId: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> Data {
        MobileIdViewModel.logger().info("Mobile-ID: Getting session request")
        let sessionResponse = try await mobileIdSignService.getSessionRequest(
            url: "\(midUrl)\(MobileIdViewModel.signatureSessionEndpoint)",
            sessionId: sessionId,
            pollingTimeout: Constants.Signing.DefaultTimeout,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )

        guard let signatureData = sessionResponse.signature?.value else {
            throw MobileIdError.technicalError
        }

        return signatureData
    }

    private func prepareSignature(
        cert: Data,
        containerFile: URL,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol,
        userAgent: String
    ) async throws -> Data {
        MobileIdViewModel.logger().info(
            "Mobile-ID: Preparing signature. Calculating hash"
        )

        return try await signedContainer.prepareSignature(
            cert: cert,
            containerPath: containerFile,
            roleData: roleData,
            userAgent: userAgent
        )
    }

    private func getVerificationCode(hash: Data) async throws -> String {
        MobileIdViewModel.logger().info(
            "Mobile-ID: Calculating verification code (control code)"
        )
        guard let verificationCode = await mobileIdSignService.getVerificationCode(hash: hash) else {
            MobileIdViewModel.logger().error("Unable to get Mobile-ID verification code")
            mobileIdErrorMessageKey = "General error"
            throw MobileIdError.generalError
        }

        return verificationCode
    }

    private func getContainerFile(signedContainer: SignedContainerProtocol) async throws -> URL {
        guard let containerFile = await signedContainer.getRawContainerFile() else {
            MobileIdViewModel.logger().error(
                "Unable to sign with Mobile-ID. Unable to get container file"
            )
            mobileIdErrorMessageKey = "General error"
            throw MobileIdError.generalError
        }

        return containerFile
    }

    private func getUUID() async -> String {
        return await dataStore.getRelyingPartyUUID()
    }

    private func getTrustedCertificates(certificates: [Data]) -> [SecCertificate] {
        MobileIdViewModel.logger().info("Mobile-ID: Getting trusted certificates list")
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
        MobileIdViewModel.logger().error("Unable to sign container with Mobile-ID: \(error)")

        if let cancellationError = error as? CancellationError {
            MobileIdViewModel.logger().error("Mobile-ID signing manually cancelled: \(cancellationError)")
            // Do not throw an error if user cancelled signing with back button
            return
        }

        guard let mobileIdError = error as? MobileIdError else {
            mobileIdErrorMessageKey = "General error"
            return
        }

        switch mobileIdError {
        case .notMidClient:
            mobileIdErrorMessageKey = "Not a mobile-id client"

        case .generalError, .uninitializedSession:
            mobileIdErrorMessageKey = "General error"

        case .explicitlyCancelled:
            // Do not throw an error if user cancelled signing with back button
            MobileIdViewModel.logger().info("Mobile-ID signing manually cancelled")
            mobileIdErrorMessageKey = nil

        case .timeout:
            mobileIdErrorMessageKey = "Expired mobile-ID transaction"

        case .incorrectParameters:
            mobileIdErrorMessageKey = "Mobile-ID incorrect parameters"

        case .userCancelled:
            mobileIdErrorMessageKey = "User denied or cancelled"

        case .signatureHashMismatch:
            mobileIdErrorMessageKey = "Failed mobile-ID transaction"

        case .phoneAbsent:
            mobileIdErrorMessageKey = "Phone is not in coverage area"

        case .deliveryError:
            mobileIdErrorMessageKey = "Request sending error"

        case .simError:
            mobileIdErrorMessageKey = "SIM error"

        case .noInternetConnection:
            mobileIdErrorMessageKey = "No Internet connection"

        case .tooManyRequests:
            showMobileIdAlertMessage = true
            mobileIdAlertMessageKey = "Too many requests"
            mobileIdAlertMessageUrl = "Too many requests url"
            mobileIdAlertMessageExtraArguments = ["Mobile-ID"]

        case .exceededUnsuccessfulRequests:
            mobileIdErrorMessageKey = "Exceeded unsuccessful requests"

        case .invalidAccessRights:
            showMobileIdAlertMessage = true
            mobileIdAlertMessageKey = "Invalid signing access rights"
            mobileIdAlertMessageUrl = "Invalid signing access rights url"
            mobileIdAlertMessageExtraArguments = ["Mobile-ID"]

        case .technicalError:
            mobileIdErrorMessageKey = "Signing technical error"
            mobileIdAlertMessageExtraArguments = ["Mobile-ID"]
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func handleSignatureAddingError(_ error: Error) {
        MobileIdViewModel.logger().error("Unable to sign container with Mobile-ID: \(error)")

        if let cancellationError = error as? CancellationError {
            MobileIdViewModel.logger().error("Mobile-ID signing manually cancelled: \(cancellationError)")
            return
        }

        guard let digidocError = error as? DigiDocError else {
            mobileIdErrorMessageKey = "General error"
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
                mobileIdErrorMessageKey = "SSL handshake failed"

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
                mobileIdErrorMessageKey = "Certificate status revoked"

            case message.contains(connectError), message.contains(failedToConnectError):
                mobileIdErrorMessageKey = "No Internet connection"

            case message.contains(proxyError):
                mobileIdErrorMessageKey = "Invalid proxy settings"

            default:
                mobileIdErrorMessageKey = "Signing technical error"
                mobileIdAlertMessageExtraArguments = ["Mobile-ID"]
            }

        default:
            mobileIdErrorMessageKey = "General error"
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
