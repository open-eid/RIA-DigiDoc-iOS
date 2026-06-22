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
import CoreNFC
import nfclib
import LibdigidocLibSwift
import UtilsLib

@MainActor
public class NFCOperationBase: NSObject, Loggable, @MainActor NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?
    var isFinished = false
    var canNumber: String = ""
    var nfcError: String = ""
    var strings: NFCSessionStrings?
    var didCompleteSuccessfully = false
    var operationError: Error?

    let connection = NFCConnection()

    func updateAlertMessage(step: Int) {
        let stepMessages = [
            strings?.initialMessage ?? "",
            strings?.step1Message ?? "",
            strings?.step2Message ?? "",
            strings?.step3Message ?? "",
            strings?.step4Message ?? ""
        ]

        let stepMessage = stepMessages[min(step, stepMessages.count - 1)]
        let progressBar = ProgressBar(currentStep: step)
        var message = stepMessage
        Self.logger().info("NFC: Updating alert message to: \(message)")
        message += "\n\n\(progressBar.generate())"
        session?.alertMessage = message
    }

    func success() {
        didCompleteSuccessfully = true
        session?.alertMessage = strings?.successMessage ?? ""
        session?.invalidate()
    }

    func handleIdCardError(_ error: IdCardError) {
        Self.logger().error("NFC: Handling IdCardError: \(error)")

        switch error {
        case .wrongCAN:
            nfcError = strings?.canErrorMessage ?? ""
        case .wrongPIN(let triesLeft):
            if triesLeft > 1 {
                nfcError = strings?.pinWrongMultipleErrorMessage ?? ""
            } else if triesLeft == 1 {
                nfcError = strings?.pinWrongErrorMessage ?? ""
            } else {
                nfcError = strings?.pinBlockedErrorMessage ?? ""
            }
        case .sessionError:
            nfcError = strings?.sessionErrorMessage ?? ""
        case .notActivated:
            nfcError = strings?.courierCardErrorMessage ?? ""
        default:
            nfcError = strings?.technicalErrorMessage ?? ""
        }
    }

    func handleNoCertLockError(
        error: Error,
        session: NFCTagReaderSession
    ) {
        Self.logger().error("NFC: Failed to find lock for cert, error: \(error)")
        nfcError = strings?.wrongCardErrorMessage ?? ""
        operationError = DecryptError.noCertLock
        session.invalidate(errorMessage: nfcError)
    }

    func handleIdCardInternalError(
        _ error: IdCardInternalError,
        session: NFCTagReaderSession
    ) {
        let idCardError = error.getIdCardError()
        Self.logger().error("NFC: IdCardError detected: \(idCardError)")
        operationError = error
        handleIdCardError(idCardError)
        session.invalidate(errorMessage: nfcError)
    }

    func handleIdCardInternalError(
        _ error: nfclib.IdCardInternalError,
        session: NFCTagReaderSession
    ) {
        let idCardError = IdCardError(error.getIdCardError())
        Self.logger().error("NFC: IdCardError detected: \(idCardError)")
        operationError = error
        handleIdCardError(idCardError)
        session.invalidate(errorMessage: nfcError)
    }

    func handleDigiDocError(
        _ error: DigiDocError,
        session: NFCTagReaderSession
    ) {
        Self.logger().error("NFC: Handling DigiDocError: \(error)")

        switch error {
        case .signatureAddingFailed(let underlying):
            handleDigiDocSignError(errorDetail: underlying)
        default:
            nfcError = strings?.technicalErrorMessage ?? ""
        }
        operationError = error
        session.invalidate(errorMessage: nfcError)
    }

    private func handleDigiDocSignError(errorDetail: ErrorDetail) {
        switch errorDetail.code {
        case 5, 6:
            nfcError = strings?.certificateRevokedErrorMessage ?? ""
        case 7:
            nfcError = strings?.ocspTimeslotErrorMessage ?? ""
        case 18:
            nfcError = strings?.tooManyRequestsErrorMessage ?? ""
        case 20:
            nfcError = strings?.networkErrorMessage ?? ""
        case 101, 102:
            nfcError = strings?.sslErrorMessage ?? ""
        default:
            nfcError = strings?.technicalErrorMessage ?? ""
        }
    }

    func handleUnknownError(
        _ error: Error,
        session: NFCTagReaderSession
    ) {
        Self.logger().error("NFC: Unknown error type: \(type(of: error))")
        Self.logger().error("NFC: Error details: \(error.localizedDescription)")
        operationError = error
        session.invalidate(errorMessage: strings?.sessionErrorMessage ?? "")
    }

    // MARK: - NFCTagReaderSessionDelegate

    public func tagReaderSessionDidBecomeActive(_: NFCTagReaderSession) { }

    public func tagReaderSession(_: NFCTagReaderSession, didDetect _: [NFCTag]) {
        // Override in subclasses
    }

    public func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError _: Error) {
        // Override in subclasses
    }
}
