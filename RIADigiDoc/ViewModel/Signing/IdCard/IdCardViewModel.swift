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
import CryptoSwift
import IdCardLib
import CommonsLib
import X509
import UtilsLib
import LibdigidocLibSwift

@Observable
@MainActor
class IdCardViewModel: IdCardViewModelProtocol, Loggable {
    private let idCardRepository: IdCardRepositoryProtocol
    private let sharedMyEidSession: SharedMyEidSessionProtocol
    private let certificateUtil: CertificateUtilProtocol
    private let nameUtil: NameUtilProtocol
    private let dataStore: DataStoreProtocol
    private let userAgentUtil: UserAgentUtilProtocol

    var errorMessage: String?
    var errorExtraArguments: [String] = []
    var shouldDismissForError = false
    var showIdCardAlertMessage = false
    var idCardAlertMessageKey: String?
    var idCardAlertMessageUrl: String?
    var idCardAlertMessageExtraArguments: [String] = []

    var pinNumberErrorKey: String?
    var pinNumberErrorExtraArguments: [String] = []

    var usbReaderStatus: UsbReaderStatus {
        sharedMyEidSession.usbReaderStatus
    }

    init(
        idCardRepository: IdCardRepositoryProtocol,
        sharedMyEidSession: SharedMyEidSessionProtocol,
        certificateUtil: CertificateUtilProtocol,
        nameUtil: NameUtilProtocol,
        dataStore: DataStoreProtocol,
        userAgentUtil: UserAgentUtilProtocol
    ) {
        self.idCardRepository = idCardRepository
        self.sharedMyEidSession = sharedMyEidSession
        self.certificateUtil = certificateUtil
        self.nameUtil = nameUtil
        self.dataStore = dataStore
        self.userAgentUtil = userAgentUtil
    }

    func startDiscoveringReaders() async {
        await idCardRepository.startDiscoveringReaders()
    }

    func stopDiscoveringReaders() async {
        await idCardRepository.stopDiscoveringReaders()
        sharedMyEidSession.stopStatusStream()
    }

    func isActionEnabled(pinNumber: String, pinType: CodeType?) -> Bool {
        checkPINNumberValidity(pinNumber: pinNumber, pinType: pinType)
        let result = (!pinNumber.isEmpty && pinNumberErrorKey?.isEmpty == true)
        return result
    }

    func decrypt(
        pin1: String,
        cryptoContainer: CryptoContainerProtocol?,
    ) async
    -> CryptoContainerProtocol? {
        do {
            let containerFile = await cryptoContainer?.getRawContainerFile() ?? URL(fileURLWithPath: "")
            let recipients = await cryptoContainer?.getRecipients() ?? []
            let pinSecureData = SecureData(Array(pin1.utf8))

            let cardCommands = try await idCardRepository.getCardHandler()
            
            let (retryCount, _) = try await idCardRepository.readCodeTryCounterRecord(for: .pin1)
            
            if retryCount == 0 {
                throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
            }
            
            let authCertData = try await idCardRepository.readAuthenticationCertificate()
            let container = try await CryptoContainer.decrypt(
                containerFile: containerFile,
                recipients: recipients,
                cert: authCertData,
                cardCommands: cardCommands,
                pin: pinSecureData,
            )

            return container
        } catch {
            IdCardViewModel.logger().error("ID-CARD: Unable to decrypt container with ID-card reader. \(error)")
            guard let exception = error as? IdCardInternalError else {
                IdCardViewModel.logger().error("ID-CARD: ID Card General error.")
                errorMessage = "General error"
                errorExtraArguments = []
                return nil
            }

            let error  = exception.getIdCardError()
            handleIdCardError(error, pinType: CodeType.pin1)

            return nil
        }
    }

    func sign(
        pin2: String,
        signedContainer: SignedContainerProtocol,
        roleData: RoleData
    ) async -> SignedContainerProtocol? {
        do {
            let containerFile = await signedContainer.getRawContainerFile() ?? URL(fileURLWithPath: "")
            let pinSecureData = SecureData(Array(pin2.utf8))
            
            let (retryCount, pinActive) = try await idCardRepository.readCodeTryCounterRecord(for: .pin2)
            
            if retryCount == 0 {
                throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
            }
            if !pinActive {
                throw IdCardInternalError.pinLocked
            }
            
            let signatureCertificate = try await idCardRepository.readSignatureCertificate()

            IdCardViewModel.logger().info("ID-CARD: Getting language")
            let appLanguage = await dataStore.getSelectedLanguage()

            IdCardViewModel.logger().info("ID-CARD: Getting User-Agent")
            let userAgent = userAgentUtil.userAgent(diagnostics: .devices, language: appLanguage)

            let dataToSign: Data
            do {
                dataToSign = try await prepareSignature(
                    cert: signatureCertificate,
                    containerFile: containerFile,
                    roleData: roleData,
                    signedContainer: signedContainer,
                    userAgent: userAgent
                )
            } catch {
                IdCardViewModel.logger().error(
                    "ID-CARD: Unable to prepare signature for signing with ID-card reader. \(error)"
                )
                handleError(error, codeType: .pin2)
                return nil
            }

            let signatureData = try await idCardRepository.calculateSignature(
                for: dataToSign,
                pin2: pinSecureData
            )

            return try await signedContainer.addSignature(
                signature: signatureData,
                containerFile: containerFile
            )
        } catch {
            IdCardViewModel.logger().error(
                "ID-CARD: Unable to read ID-card data to sign with ID-Card reader. \(error)"
            )

            handleError(error, codeType: .pin2)
            return nil
        }
    }

    func getIdCardData(for codeType: CodeType) async -> IdCardData? {
        do {
            let publicData = try await getPublicData()
            let authCertNotValidDate = try await readAuthenticationCertificateNotValidDate()
            let signCertNotValidDate = try await readSignatureCertificateNotValidDate()
            let pinResponse = try await readCodeTryCounterRecord()
            let isPUKChangeable = try await isPukChangeable()

            if (codeType == CodeType.pin1) {
                if pinResponse.pin1RetryCount == 0 {
                    throw IdCardInternalError.remainingPinRetryCount(0)
                }
            }
            if (codeType == CodeType.pin2) {
                if pinResponse.pin2RetryCount == 0 {
                    throw IdCardInternalError.remainingPinRetryCount(0)
                }
            }
            
            if !pinResponse.pin2Active {
                throw IdCardInternalError.pinLocked
            }
            
            return IdCardData(
                publicData: publicData,
                authCertNotValidDate: authCertNotValidDate,
                signCertNotValidDate: signCertNotValidDate,
                pinResponse: pinResponse,
                isPUKChangeable: isPUKChangeable
            )
        } catch {
            IdCardViewModel.logger().error(
                "Unable to read ID-card data. \(error)"
            )

            handleError(error, codeType: codeType)
            return nil
        }
    }
    
    func getIdCardDataMyEid() async -> IdCardData? {
        do {
            let publicData = try await getPublicData()
            let authCertNotValidDate = try await readAuthenticationCertificateNotValidDate()
            let signCertNotValidDate = try await readSignatureCertificateNotValidDate()
            let pinResponse = try await readCodeTryCounterRecord()
            let isPUKChangeable = try await isPukChangeable()
            
            return IdCardData(
                publicData: publicData,
                authCertNotValidDate: authCertNotValidDate,
                signCertNotValidDate: signCertNotValidDate,
                pinResponse: pinResponse,
                isPUKChangeable: isPUKChangeable
            )
        } catch {
            IdCardViewModel.logger().error(
                "Unable to read ID-card data. \(error)"
            )

            errorMessage = "General error"
            errorExtraArguments = []
            return nil
        }
    }

    func resetErrors() {
        errorMessage = nil
        errorExtraArguments = []
        shouldDismissForError = false
    }

    func resetAlertErrors() {
        showIdCardAlertMessage = false
        idCardAlertMessageKey = nil
        idCardAlertMessageUrl = nil
        idCardAlertMessageExtraArguments = []
    }

    func formatPersonalIdentifier(givenName: String, surname: String, personalCode: String) -> String {
        return "\(nameUtil.formatName("\(givenName) \(surname)")), \(personalCode)"
    }

    func isRoleDataEnabled() async -> Bool {
        await dataStore.getIsRoleAndAddressEnabled()
    }

    private func getPublicData() async throws -> CardInfo {
        IdCardViewModel.logger().info(
            "ID-CARD: Getting public data from ID-card with reader"
        )

        return try await idCardRepository.getPublicData()
    }

    private func readAuthenticationCertificateNotValidDate() async throws -> String? {
        IdCardViewModel.logger().info(
            "Reading authentication certificate from ID-card with reader"
        )

        let authCertData = try await idCardRepository.readAuthenticationCertificate()
        let authCertificate = certificateUtil.certificate(from: authCertData)
        guard let authCert = authCertificate else { return nil }
        return try getNotValidDate(from: authCert)
    }

    private func readSignatureCertificateNotValidDate() async throws -> String? {
        IdCardViewModel.logger().info(
            "ID-CARD: Reading signature certificate from ID-card with reader"
        )

        let signCertData = try await idCardRepository.readSignatureCertificate()
        let signCertificate = certificateUtil.certificate(from: signCertData)
        guard let signCert = signCertificate else { return nil }
        return try getNotValidDate(from: signCert)
    }

    private func readCodeTryCounterRecord() async throws -> PinResponse {
        IdCardViewModel.logger().info(
            "ID-CARD: Reading retry counter record from ID-card with reader"
        )

        let pin1Response = try await idCardRepository.readCodeTryCounterRecord(for: .pin1)
        let pin2Response = try await idCardRepository.readCodeTryCounterRecord(for: .pin2)
        let pukResponse = try await idCardRepository.readCodeTryCounterRecord(for: .puk)
        return PinResponse(
            pin1RetryCount: pin1Response.retryCount,
            pin1Active: pin1Response.pinActive,
            pin2RetryCount: pin2Response.retryCount,
            pin2Active: pin2Response.pinActive,
            pukRetryCount: pukResponse.retryCount,
            pukActive: pukResponse.pinActive,
        )
    }

    private func isPukChangeable() async throws -> Bool {
        IdCardViewModel.logger().info(
            "ID-CARD: Reading if PUK is changeable for this ID-card with reader"
        )

        return try await idCardRepository.isPUKChangeable()
    }

    private func getNotValidDate(from certificate: SecCertificate) throws -> String? {
        let certificate = try Certificate(certificate)
        let notValidAfter = certificate.notValidAfter
        return DateUtil.getFormattedDateTime(
            date: notValidAfter,
            isUTC: false
        ).date
    }

    private func handleIdCardError(_ error: IdCardError, pinType: CodeType) {
        IdCardViewModel.logger().error("ID-CARD: ID Card error: \(error)")

        switch error {
        case .cancelledByUser:
            errorMessage = nil
            errorExtraArguments = []
            shouldDismissForError = true
        case .pinLocked:
            showIdCardAlertMessage = true
            idCardAlertMessageKey = "PIN2 locked"
            idCardAlertMessageUrl = "PIN2 locked URL"
        case .wrongPIN(let triesLeft):
            if triesLeft > 1 {
                errorMessage = "PIN verification error multiple"
                errorExtraArguments = [pinType.name, String(triesLeft)]
            } else if triesLeft == 1 {
                errorMessage = "PIN verification error one"
                errorExtraArguments = [pinType.name]
            } else {
                errorMessage = "PIN blocked"
                errorExtraArguments = [pinType.name]
                shouldDismissForError = true
            }
        case .sessionError:
            errorMessage = "General error"
            errorExtraArguments = []
            shouldDismissForError = true
        default:
            errorMessage = "General error"
            errorExtraArguments = []
            shouldDismissForError = true
        }
    }

    private func checkPINNumberValidity(pinNumber: String, pinType: CodeType?) {
        let minLen = if pinType == .pin1 {
            Constants.Validation.Pin1MinimumLength
        } else if pinType == .pin2 {
            Constants.Validation.Pin2MinimumLength
        } else {
            Constants.Validation.PukMinimumLength
        }

        let maxLen = Constants.Validation.PinMaximumLength

        guard pinNumber.isEmpty || (
            pinNumber.count >= minLen &&
            pinNumber.count <= maxLen &&
            pinNumber.allSatisfy { $0.isNumber }
        ) else {
            pinNumberErrorKey = "PIN length requirement"
            pinNumberErrorExtraArguments = [pinType?.name ?? "", String(minLen), String(maxLen)]
            return
        }
        pinNumberErrorKey = ""
    }

    private func prepareSignature(
        cert: Data,
        containerFile: URL,
        roleData: RoleData,
        signedContainer: SignedContainerProtocol,
        userAgent: String
    ) async throws -> Data {
        IdCardViewModel.logger().info(
            "ID-CARD: Preparing signature. Calculating hash"
        )

        return try await signedContainer.prepareSignature(
            cert: cert,
            containerPath: containerFile,
            roleData: roleData,
            userAgent: userAgent
        )
    }

    private func handleError(_ error: Error, codeType: CodeType) {
        switch error {
        case let idCardError as IdCardError:
            handleIdCardError(idCardError, pinType: codeType)

        case let digidocError as DigiDocError:
            handleSignatureAddingError(digidocError)

        default:
            errorMessage = "General error"
            errorExtraArguments = []
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func handleSignatureAddingError(_ error: Error) {
        IdCardViewModel.logger().error("Unable to sign container with ID-card: \(error)")

        if let cancellationError = error as? CancellationError {
            IdCardViewModel.logger().error("ID-card signing manually cancelled: \(cancellationError)")
            return
        }

        guard let digidocError = error as? DigiDocError else {
            errorMessage = "General error"
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
                errorMessage = "SSL handshake failed"

            case message.contains(tooManyRequestsError):
                showIdCardAlertMessage = true
                idCardAlertMessageKey = "Too many requests"
                idCardAlertMessageUrl = "Too many requests url"
                idCardAlertMessageExtraArguments = ["ID card conditional speech"]

            case message.contains(ocspError):
                showIdCardAlertMessage = true
                idCardAlertMessageKey = "OCSP response not in valid time slot"
                idCardAlertMessageUrl = "OCSP response not in valid time slot url"

            case message.contains(revokedCertError):
                errorMessage = "Certificate status revoked"

            case message.contains(connectError), message.contains(failedToConnectError):
                errorMessage = "No Internet connection"

            case message.contains(proxyError):
                errorMessage = "Invalid proxy settings"

            default:
                errorMessage = "Signing technical error"
                idCardAlertMessageExtraArguments = ["ID card conditional speech"]
            }

        default:
            errorMessage = "General error"
        }
    }
}
