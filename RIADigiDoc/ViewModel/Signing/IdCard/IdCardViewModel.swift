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

@Observable
@MainActor
class IdCardViewModel: IdCardViewModelProtocol, Loggable {
    private let idCardRepository: IdCardRepositoryProtocol
    private let sharedMyEidSession: SharedMyEidSessionProtocol
    private let certificateUtil: CertificateUtilProtocol
    private let nameUtil: NameUtilProtocol

    var errorMessage: String?
    var errorExtraArguments: [String] = []
    var shouldDismissForError = false

    var pinNumberErrorKey: String?
    var pinNumberErrorExtraArguments: [String] = []

    var usbReaderStatus: UsbReaderStatus {
        sharedMyEidSession.usbReaderStatus
    }

    init(
        idCardRepository: IdCardRepositoryProtocol,
        sharedMyEidSession: SharedMyEidSessionProtocol,
        certificateUtil: CertificateUtilProtocol,
        nameUtil: NameUtilProtocol
    ) {
        self.idCardRepository = idCardRepository
        self.sharedMyEidSession = sharedMyEidSession
        self.certificateUtil = certificateUtil
        self.nameUtil = nameUtil
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

    func getIdCardData() async -> IdCardData? {
        do {
            let publicData = try await getPublicData()
            let authCertNotValidDate = try await readAuthenticationCertificateNotValidDate()
            let signCertNotValidDate = try await readSignatureCertificateNotValidDate()
            let retryCount = try await readCodeTryCounterRecord()
            let isPUKChangeable = try await isPukChangeable()

            return IdCardData(
                publicData: publicData,
                authCertNotValidDate: authCertNotValidDate,
                signCertNotValidDate: signCertNotValidDate,
                retryCount: retryCount,
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

    func formatPersonalIdentifier(givenName: String, surname: String, personalCode: String) -> String {
        return "\(nameUtil.formatName("\(givenName) \(surname)")), \(personalCode)"
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

    private func readCodeTryCounterRecord() async throws -> RetryCount {
        IdCardViewModel.logger().info(
            "ID-CARD: Reading retry counter record from ID-card with reader"
        )

        let pin1RetryCount = try await idCardRepository.readCodeTryCounterRecord(for: .pin1)
        let pin2RetryCount = try await idCardRepository.readCodeTryCounterRecord(for: .pin2)
        let pukRetryCount = try await idCardRepository.readCodeTryCounterRecord(for: .puk)
        return RetryCount(
            pin1: pin1RetryCount,
            pin2: pin2RetryCount,
            puk: pukRetryCount
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
}
