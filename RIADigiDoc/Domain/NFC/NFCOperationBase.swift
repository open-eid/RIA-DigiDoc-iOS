// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import nfclib
import LibdigidocLibSwift
import CryptoSwift
import UtilsLib

@MainActor
public class NFCOperationBase: NSObject, Loggable {
    var strings: NFCSessionStrings?
    private var connection: NFCConnection?

    public var onStepChange: (@MainActor (Int) -> Void)?

    func updateAlertMessage(step: Int) {
        connection?.message(alertMessage(step: step))
        onStepChange?(step)
    }

    private func alertMessage(step: Int) -> String {
        let stepMessages = [
            strings?.initialMessage ?? "",
            strings?.step1Message ?? "",
            strings?.step2Message ?? "",
            strings?.step3Message ?? "",
            strings?.step4Message ?? ""
        ]

        let stepMessage = stepMessages[min(step, stepMessages.count - 1)]
        let progressBar = ProgressBar(currentStep: step)
        Self.logger().info("NFC: Updating alert message to: \(stepMessage)")
        return stepMessage + "\n\n\(progressBar.generate())"
    }

    func withCardCommands<T>(
        canNumber: String,
        strings: NFCSessionStrings,
        _ body: (any CardCommands) async throws -> T
    ) async throws -> T {
        self.strings = strings
        return try await NFCConnection.run(successMessage: strings.successMessage, onError: { error in
            Self.logger().error("Unable to complete NFC operation: \(String(describing: error))")
            return failure(for: error, strings: strings)
        }) { connection in
            self.connection = connection
            defer { self.connection = nil }
            try Task.checkCancellation()
            onStepChange?(0)
            let cardCommands = try await connection.connect(
                CAN: canNumber,
                message: alertMessage(step: 0),
                detectedMessage: alertMessage(step: 2)
            )
            return try await body(cardCommands)
        }
    }

    // MARK: - Error handling

    /// The error to throw to the caller and the text to show in the NFC sheet.
    private func failure(for error: Error, strings: NFCSessionStrings) -> (error: Error, message: String) {
        switch error {
        case nfclib.IdCardInternalError.cancelledByUser:
            return (IdCardInternalError.cancelledByUser, strings.sessionErrorMessage)
        case let nsError as NSError where nsError.localizedDescription == "Failed to find lock for cert":
            Self.logger().error("NFC: Failed to find lock for cert, error: \(error)")
            return (DecryptError.noCertLock, strings.wrongCardErrorMessage)
        case let idCardInternalError as IdCardInternalError:
            let idCardError = idCardInternalError.getIdCardError()
            Self.logger().error("NFC: IdCardError detected: \(idCardError)")
            return (idCardInternalError, idCardErrorMessage(idCardError, strings: strings))
        case let nfcIdCardError as nfclib.IdCardInternalError:
            let idCardError = IdCardError(nfcIdCardError.getIdCardError())
            Self.logger().error("NFC: IdCardError detected: \(idCardError)")
            return (nfcIdCardError, idCardErrorMessage(idCardError, strings: strings))
        case let readCertSignError as ReadCertAndSignError:
            Self.logger().error("NFC: ReadCertAndSignError: \(readCertSignError.localizedDescription)")
            return (readCertSignError, strings.technicalErrorMessage)
        case let digiDocError as DigiDocError:
            Self.logger().error("NFC: Handling DigiDocError: \(digiDocError)")
            return (digiDocError, digiDocErrorMessage(digiDocError, strings: strings))
        case let nsError as NSError where nsError.isCryptoNetworkError:
            Self.logger().error("NFC: Unable to reach the key server")
            return (error, strings.networkErrorMessage)
        default:
            Self.logger().error("NFC: Unknown error type: \(type(of: error))")
            Self.logger().error("NFC: Error details: \(String(describing: error))")
            return (error, strings.sessionErrorMessage)
        }
    }

    private func idCardErrorMessage(_ error: IdCardError, strings: NFCSessionStrings) -> String {
        Self.logger().error("NFC: Handling IdCardError: \(error)")

        return switch error {
        case .wrongCAN:
            strings.canErrorMessage
        case .wrongPIN(let triesLeft) where triesLeft > 1:
            strings.pinWrongMultipleErrorMessage
        case .wrongPIN(1):
            strings.pinWrongErrorMessage
        case .wrongPIN:
            strings.pinBlockedErrorMessage
        case .sessionError:
            strings.sessionErrorMessage
        case .notActivated:
            strings.courierCardErrorMessage
        case .pinLocked:
            strings.pinLockedErrorMessage
        default:
            strings.technicalErrorMessage
        }
    }

    private func digiDocErrorMessage(_ error: DigiDocError, strings: NFCSessionStrings) -> String {
        guard case .signatureAddingFailed(let errorDetail) = error else {
            return strings.technicalErrorMessage
        }
        return switch errorDetail.code {
        case 5, 6:
            strings.certificateRevokedErrorMessage
        case 7:
            strings.ocspTimeslotErrorMessage
        case 18:
            strings.tooManyRequestsErrorMessage
        case 20:
            strings.networkErrorMessage
        case 101, 102:
            strings.sslErrorMessage
        default:
            strings.technicalErrorMessage
        }
    }
}
