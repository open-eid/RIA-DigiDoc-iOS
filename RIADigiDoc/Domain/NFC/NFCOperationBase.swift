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
import CoreNFC
import IdCardLib
import UtilsLib

@MainActor
public class NFCOperationBase: NSObject, Loggable, @MainActor NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?
    var isFinished = false
    var canNumber: String = ""
    var nfcError: String = ""
    var strings: NFCSessionStrings?

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
        default:
            nfcError = strings?.technicalErrorMessage ?? ""
        }
    }

    func handleIdCardInternalError(
        _ error: IdCardInternalError,
        session: NFCTagReaderSession
    ) {
        let idCardError = error.getIdCardError()
        Self.logger().error("NFC: IdCardError detected: \(idCardError)")
        handleIdCardError(idCardError)
        session.invalidate(errorMessage: nfcError ?? "")
    }

    func handleUnknownError(
        _ error: Error,
        session: NFCTagReaderSession
    ) -> Error {
        Self.logger().error("NFC: Unknown error type: \(type(of: error))")
        Self.logger().error("NFC: Error details: \(error.localizedDescription)")
        session.invalidate(errorMessage: strings?.sessionErrorMessage ?? "")
        return error
    }

    func checkIfFinished(error: Error) -> Bool {
        guard !isFinished else {
            Self.logger().info("NFC: Operation already finished, ignoring error: \(error.localizedDescription)")
            return true
        }
        isFinished = true
        return false
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
