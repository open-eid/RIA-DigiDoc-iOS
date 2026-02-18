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

import UIKit
import Alamofire
import SmartIdLib
import LibdigidocLibSwift
import UtilsLib
import ConfigLib
import CommonsLib
import CryptoKit
import ActivityKit

@Observable
@MainActor
class SmartIdViewModel: SmartIdViewModelProtocol, Loggable {

    private var activity: Activity<WidgetExtensionAttributes>?

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private static let certificateEndpoint = "/certificatechoice/etsi"
    private static let signatureEndpoint = "/signature/document"
    private static let sessionEndpoint = "/session"

    var controlCode: String = "- - - -"
    var infoMessage: String = "Smart-ID signing info message"

    var personalCodeErrorKey: String?

    var smartIdMessageKey: String?
    var smartIdAlertMessageKey: String?
    var smartIdAlertMessageExtraArguments: [String] = []
    var showSmartIdAlertMessage: Bool = false
    var smartIdAlertMessageUrl: String?

    private let configurationRepository: ConfigurationRepositoryProtocol
    private let smartIdSignService: SmartIdSignServiceProtocol
    private let certificateUtil: CertificateUtilProtocol
    private let notificationUtil: NotificationUtilProtocol
    private let dataStore: DataStoreProtocol
    private let proxyUtil: ProxyUtilProtocol
    private let userAgentUtil: UserAgentUtilProtocol

    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        smartIdSignService: SmartIdSignServiceProtocol,
        certificateUtil: CertificateUtilProtocol,
        notificationUtil: NotificationUtilProtocol,
        dataStore: DataStoreProtocol,
        proxyUtil: ProxyUtilProtocol,
        userAgentUtil: UserAgentUtilProtocol
    ) {
        self.configurationRepository = configurationRepository
        self.smartIdSignService = smartIdSignService
        self.certificateUtil = certificateUtil
        self.notificationUtil = notificationUtil
        self.dataStore = dataStore
        self.proxyUtil = proxyUtil
        self.userAgentUtil = userAgentUtil
    }

    func appDidEnterBackground() {
        startBackgroundTask()
    }

    func appDidBecomeActive() {
        endBackgroundTask()
    }

    func isSigningEnabled(
        personalCode: String
    ) -> Bool {
        checkPersonalCodeValidity(personalCode)
        return !personalCode.isEmpty && personalCodeErrorKey?.isEmpty == true
    }

    func saveInputData(
        country: SmartIdCountry,
        personalCode: String,
        rememberMe: Bool
    ) async {
        await dataStore
            .setSmartIdInputData(
                SmartIdInputData(
                    country: country,
                    personalCode: personalCode,
                    rememberMe: rememberMe
                )
            )
    }

    func getInputData() async -> SmartIdInputData {
        return await dataStore.getSmartIdInputData()
    }

    func resetErrors() {
        smartIdMessageKey = nil
        smartIdAlertMessageKey = nil
        smartIdAlertMessageExtraArguments = []
        showSmartIdAlertMessage = false
        smartIdAlertMessageUrl = nil
    }

    // swiftlint:disable:next cyclomatic_complexity
    func sign(
        country: SmartIdCountry,
        personalCode: String,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol,
        liveActivityTexts: SmartIdLiveActivityTexts
    ) async -> SignedContainerProtocol? {
        SmartIdViewModel.logger().info("Smart-ID: Signing with Smart-ID")

        let currentConfiguration = await configurationRepository.getConfiguration()

        guard let configuration = currentConfiguration else {
            SmartIdViewModel.logger().error(
                "Smart-ID: Unable to get configuration to sign with Smart-ID"
            )
            smartIdMessageKey = "General error"
            return nil
        }

        let savedUuid = await getUUID()
        let uuid = savedUuid.isEmpty ? Constants.Signing.RelyingPartyUUID : savedUuid
        let sidUrl = (
            uuid.isEmpty || uuid == Constants.Signing.RelyingPartyUUID
        ) ? configuration.sidV2RestUrl : configuration.sidV2SkRestUrl
        let certBundle = configuration.certBundle

        let trustedCertificates = getTrustedCertificates(certificates: certBundle)

        let proxyInfo = await proxyUtil.getProxyInfo()

        SmartIdViewModel.logger().info("Smart-ID: Getting language")
        let appLanguage = await dataStore.getSelectedLanguage()

        SmartIdViewModel.logger().info("Smart-ID: Getting User-Agent")
        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: appLanguage)

        let containerFile: URL
        do {
            containerFile = try await getContainerFile(signedContainer: signedContainer)
        } catch {
            SmartIdViewModel.logger().info("Smart-ID: Unable to get container file from container")
            handleSigningError(error)
            return nil
        }

        var isNotificationPermissionGranted = false
        do {
            try startLiveActivity(withTexts: liveActivityTexts)
        } catch {
            SmartIdViewModel.logger().error(
                "Smart-ID: Unable to start live activity for verification code (control code). \(error)"
            )

            isNotificationPermissionGranted = await notificationUtil.requestAuthorization()
        }

        let response: SmartIdSessionResponse
        do {
            response = try await requestCertificate(
                sidUrl: sidUrl,
                country: country,
                personalCode: personalCode,
                pollingTimeout: Constants.Signing.DefaultTimeout,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )
        } catch {
            SmartIdViewModel.logger().info("Smart-ID: Unable to request certificate or get response")
            handleSigningError(error)
            return nil
        }

        guard let cert = response.cert?.value else {
            return nil
        }

        guard let documentNumber = response.result?.documentNumber else {
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
            SmartIdViewModel.logger().info("Smart-ID: Unable to prepare signature for signing")
            handleSigningError(error)
            return nil
        }

        controlCode = await getVerificationCode(hash: hash)
        infoMessage = "Smart-ID control code signing info message"

        await updateLiveActivity(withTexts: liveActivityTexts)

        var notificationIdentifier: String = ""
        do {
            if isNotificationPermissionGranted {
                notificationIdentifier = try await notificationUtil
                    .sendNotification(
                        title: NSLocalizedString(
                            "Smart-ID notification title",
                            comment: ""
                        ),
                        body: controlCode
                    )
            }
        } catch {
            SmartIdViewModel.logger().error(
                "Smart-ID: Unable to send verification code (control code) notification. \(error)"
            )
        }

        let signatureData: Data
        do {
            signatureData = try await requestSignature(
                sidUrl: sidUrl,
                documentNumber: documentNumber,
                hash: hash,
                hashType: Constants.Signing.HashType,
                allowedInteractionsOrderType: "confirmationMessageAndVerificationCodeChoice",
                displayText: NSLocalizedString("Sign document", comment: ""),
                pollingTimeout: Constants.Signing.DefaultTimeout,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )
        } catch {
            endBackgroundTask()
            SmartIdViewModel.logger().info("Smart-ID: Unable to request signature or get cert from response")
            handleSigningError(error)
            notificationUtil.removeNotification(id: notificationIdentifier)
            await endLiveActivity()
            return nil
        }

        endBackgroundTask()

        await endLiveActivity()

        do {
            try Task.checkCancellation()

            let updatedContainer = try await signedContainer.addSignature(
                signature: signatureData,
                containerFile: containerFile
            )

            SmartIdViewModel.logger().info("Signature added successfully (Smart-ID)")
            smartIdMessageKey = "Signature added"
            notificationUtil.removeNotification(id: notificationIdentifier)
            await endLiveActivity()
            return updatedContainer
        } catch {
            SmartIdViewModel.logger().error("Unable to sign container with Smart-ID: \(error)")
            handleSignatureAddingError(error)
            notificationUtil.removeNotification(id: notificationIdentifier)
            await endLiveActivity()
            return nil
        }
    }

    func isRoleDataEnabled() async -> Bool {
        await dataStore.getIsRoleAndAddressEnabled()
    }

    private func checkPersonalCodeValidity(_ personalCode: String) {
        guard personalCode.isEmpty || PersonalCodeValidator.isPersonalCodeValid(personalCode) else {
            personalCodeErrorKey = "Invalid personal code"
            return
        }
        personalCodeErrorKey = ""
    }

    private func getCountry(smartIdCountry: SmartIdCountry) -> String {
        switch smartIdCountry {
        case .estonia:
            return "EE"
        case .latvia:
            return "LV"
        case .lithuania:
            return "LT"
        }
    }

    // swiftlint:disable:next function_parameter_count
    private func requestCertificate(
        sidUrl: URL,
        country: SmartIdCountry,
        personalCode: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> SmartIdSessionResponse {
        SmartIdViewModel.logger().info("Smart-ID: Getting certificate")
        let certResponse = try await smartIdSignService
            .getCertificateRequest(
                url: "\(sidUrl)\(SmartIdViewModel.certificateEndpoint)",
                relyingPartyName: Constants.Signing.RelyingPartyName,
                relyingPartyUUID: Constants.Signing.RelyingPartyUUID,
                country: getCountry(smartIdCountry: country),
                nationalIdentityNumber: personalCode,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )

        guard let sessionId = certResponse.sessionID else {
            throw SmartIdError.missingSessionId
        }

        SmartIdViewModel.logger().info("Smart-ID: Requesting session from certificate response")

        return try await requestSession(
            sidUrl: "\(sidUrl)\(SmartIdViewModel.sessionEndpoint)",
            sessionId: sessionId,
            pollingTimout: pollingTimeout,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )
    }

    // swiftlint:disable:next function_parameter_count
    private func requestSignature(
        sidUrl: URL,
        documentNumber: String,
        hash: Data,
        hashType: String,
        allowedInteractionsOrderType: String,
        displayText: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> Data {
        SmartIdViewModel.logger().info("Smart-ID: Getting signature")

        let certResponse = try await smartIdSignService
            .getSignatureRequest(
                url: "\(sidUrl)\(SmartIdViewModel.signatureEndpoint)",
                relyingPartyName: Constants.Signing.RelyingPartyName,
                relyingPartyUUID: Constants.Signing.RelyingPartyUUID,
                documentNumber: documentNumber,
                hash: hash,
                hashType: hashType,
                allowedInteractionsOrderType: allowedInteractionsOrderType,
                displayText200: displayText,
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )

        guard let sessionId = certResponse.sessionID else {
            throw SmartIdError.missingSessionId
        }

        SmartIdViewModel.logger().info("Smart-ID: Requesting session from signature response")

        let sessionResponse = try await requestSession(
            sidUrl: "\(sidUrl)\(SmartIdViewModel.sessionEndpoint)",
            sessionId: sessionId,
            pollingTimout: pollingTimeout,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )

        guard let signature = sessionResponse.signature?.value else {
            throw SmartIdError.technicalError
        }

        return signature
    }

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    // swiftlint:disable:next function_parameter_count
    private func requestSession(
        sidUrl: String,
        sessionId: String,
        pollingTimout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> SmartIdSessionResponse {
        SmartIdViewModel.logger().info("Smart-ID: Getting session")
        return try await smartIdSignService.getSessionRequest(
            url: sidUrl,
            sessionId: sessionId,
            pollingTimeout: pollingTimout,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )
    }

    private func getUUID() async -> String {
        return await dataStore.getRelyingPartyUUID()
    }

    private func getTrustedCertificates(certificates: [Data]) -> [SecCertificate] {
        SmartIdViewModel.logger().info("Smart-ID: Getting trusted certificates list")
        return certificates.compactMap { certificateUtil.certificate(from: $0) }
    }

    private func getContainerFile(signedContainer: SignedContainerProtocol) async throws -> URL {
        guard let containerFile = await signedContainer.getRawContainerFile() else {
            SmartIdViewModel.logger().error(
                "Unable to sign with Smart-ID. Unable to get container file"
            )
            smartIdMessageKey = "General error"
            throw SmartIdError.generalError
        }

        return containerFile
    }

    private func prepareSignature(
        cert: Data,
        containerFile: URL,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol,
        userAgent: String
    ) async throws -> Data {
        SmartIdViewModel.logger().info(
            "Smart-ID: Preparing signature. Calculating hash"
        )

        return try await signedContainer.prepareSignature(
            cert: cert,
            containerPath: containerFile,
            roleData: roleData,
            userAgent: userAgent
        )
    }

    private func getVerificationCode(hash: Data) async -> String {
        SmartIdViewModel.logger().info(
            "Smart-ID: Calculating verification code (control code)"
        )
        return await smartIdSignService.getVerificationCode(digest: sha256(data: hash))
    }

    private func sha256(data: Data) -> Data {
        let hashed = SHA256.hash(data: data)
        return Data(hashed)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func handleSigningError(_ error: Error) {
        SmartIdViewModel.logger().error("Unable to sign container with Smart-ID: \(error)")

        if let cancellationError = error as? CancellationError {
            SmartIdViewModel.logger().error("Smart-ID signing manually cancelled: \(cancellationError)")
            // Do not throw an error if user cancelled signing with back button
            return
        }

        guard let smartIdError = error as? SmartIdError else {
            smartIdMessageKey = "General error"
            return
        }

        switch smartIdError {
        case .generalError, .uninitializedSession, .missingSessionId:
            smartIdMessageKey = "General error"

        case .explicitlyCancelled:
            // Do not throw an error if user cancelled signing with back button
            SmartIdViewModel.logger().info("Smart-ID signing manually cancelled")
            smartIdMessageKey = nil

        case .noInternetConnection, .noResponse:
            smartIdMessageKey = "No Internet connection"

        case .incorrectParameters:
            smartIdMessageKey = "Invalid personal code"

        case .timeout, .accountNotFound:
            smartIdMessageKey = "Expired Smart-ID transaction"

        case .documentUnusable:
            smartIdMessageKey = "Failed Smart-ID transaction"

        case .wrongVC:
            smartIdMessageKey = "Smart-ID wrong vc"

        case .userRefused:
            smartIdMessageKey = "User denied or cancelled"

        case .sessionNotFound:
            smartIdMessageKey = "Smart-ID session not found"

        case .tooManyRequests:
            showSmartIdAlertMessage = true
            smartIdAlertMessageKey = "Too many requests"
            smartIdAlertMessageUrl = "Too many requests url"
            smartIdAlertMessageExtraArguments = ["Smart-ID"]

        case .exceededUnsuccessfulRequests:
            smartIdMessageKey = "Exceeded unsuccessful requests"

        case .notQualified:
            smartIdMessageKey = "Smart-ID certificate level not qualified"

        case .invalidAccessRights:
            showSmartIdAlertMessage = true
            smartIdAlertMessageKey = "Invalid signing access rights"
            smartIdAlertMessageUrl = "Invalid signing access rights url"
            smartIdAlertMessageExtraArguments = ["Smart-ID"]

        case .oldApi:
            smartIdMessageKey = "Smart-ID old api"

        case .underMaintenance:
            smartIdMessageKey = "Smart-ID under maintenance"

        case .invalidSslHandshake:
            smartIdMessageKey = "SSL handshake failed"

        case .technicalError:
            smartIdMessageKey = "Signing technical error"
            smartIdAlertMessageExtraArguments = ["Smart-ID"]

        case .ocspInvalidTimeSlot:
            showSmartIdAlertMessage = true
            smartIdAlertMessageKey = "OCSP response not in valid time slot"
            smartIdAlertMessageUrl = "OCSP response not in valid time slot url"

        case .certificateRevoked:
            smartIdMessageKey = "Certificate status revoked"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func handleSignatureAddingError(_ error: Error) {
        SmartIdViewModel.logger().error("Unable to sign container with Smart-ID: \(error)")

        if let cancellationError = error as? CancellationError {
            SmartIdViewModel.logger().error("Smart-ID signing manually cancelled: \(cancellationError)")
            return
        }

        guard let digidocError = error as? DigiDocError else {
            smartIdMessageKey = "General error"
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
                smartIdMessageKey = "SSL handshake failed"

            case message.contains(tooManyRequestsError):
                showSmartIdAlertMessage = true
                smartIdAlertMessageKey = "Too many requests"
                smartIdAlertMessageUrl = "Too many requests url"
                smartIdAlertMessageExtraArguments = ["Smart-ID"]

            case message.contains(ocspError):
                showSmartIdAlertMessage = true
                smartIdAlertMessageKey = "OCSP response not in valid time slot"
                smartIdAlertMessageUrl = "OCSP response not in valid time slot url"

            case message.contains(revokedCertError):
                smartIdMessageKey = "Certificate status revoked"

            case message.contains(connectError), message.contains(failedToConnectError):
                smartIdMessageKey = "No Internet connection"

            case message.contains(proxyError):
                smartIdMessageKey = "Invalid proxy settings"

            default:
                smartIdMessageKey = "Signing technical error"
                smartIdAlertMessageExtraArguments = ["Smart-ID"]
            }

        default:
            smartIdMessageKey = "General error"
        }
    }

    private func startLiveActivity(withTexts texts: SmartIdLiveActivityTexts) throws {
        if UIAccessibility.isVoiceOverRunning {
            SmartIdViewModel.logger().info("Smart-ID: VoiceOver active - using local notification instead")
            throw ActivityAuthorizationError.unsupported
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            SmartIdViewModel.logger().info("Smart-ID: Live Activities not enabled - using local notification instead")
            throw ActivityAuthorizationError.denied
        }

        if let existingActivity = Activity<WidgetExtensionAttributes>.activities.first {
            self.activity = existingActivity
            return
        }

        let attributes = WidgetExtensionAttributes()
        let initialState = WidgetExtensionAttributes.ContentState(
            title: texts.initialMessage,
            compactTitle: texts.compactTitle,
            controlCode: ""
        )

        activity = try Activity.request(
            attributes: attributes,
            content: ActivityContent(
                state: initialState,
                staleDate: Date.now.addingTimeInterval(100000),
                relevanceScore: 100.0
            ),
            pushType: nil
        )

        SmartIdViewModel.logger().info("Smart-ID: Live activity started for control code")
    }

    private func updateLiveActivity(withTexts texts: SmartIdLiveActivityTexts) async {
        guard let activity = self.activity else {
            SmartIdViewModel.logger().error("Smart-ID: No active Live Activity to update")
            return
        }

        let newState = WidgetExtensionAttributes.ContentState(
            title: texts.controlCodeTitle,
            compactTitle: texts.compactTitle,
            controlCode: controlCode
        )
        let newContent = ActivityContent(
            state: newState,
            staleDate: nil
        )

        await activity.update(newContent)

        SmartIdViewModel.logger().info("Smart-ID: Live Activity updated")
    }

    func endLiveActivity() async {
        guard let activity else { return }

        let state = WidgetExtensionAttributes.ContentState(
            title: "",
            compactTitle: "",
            controlCode: ""
        )

        let content = ActivityContent(
            state: state,
            staleDate: nil
        )

        await activity.end(
            content,
            dismissalPolicy: .immediate
        )

        self.activity = nil
    }
}
