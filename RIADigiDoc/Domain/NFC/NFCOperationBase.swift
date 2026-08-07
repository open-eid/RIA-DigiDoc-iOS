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
    var nfcError: String = ""
    var strings: NFCSessionStrings?
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
        Self.logger().error("NFC: Error details: \(String(describing: error))")
        operationError = error
        session.invalidate(errorMessage: strings?.sessionErrorMessage ?? "")
    }

    func handleNFCError(_ error: Error, session: NFCTagReaderSession) -> Bool {
        if (error as NSError).localizedDescription == "Failed to find lock for cert" {
            handleNoCertLockError(error: error, session: session)
            return true
        }
        if let idCardInternalError = error as? IdCardInternalError {
            handleIdCardInternalError(idCardInternalError, session: session)
            return true
        }
        if let nfcIdCardError = error as? nfclib.IdCardInternalError {
            handleIdCardInternalError(nfcIdCardError, session: session)
            return true
        }
        return false
    }

    func handleSessionError(_ error: Error, session: NFCTagReaderSession) -> Error {
        if let nfcError = error as? NFCReaderError,
           nfcError.code == .readerSessionInvalidationErrorUserCanceled {
            return IdCardInternalError.cancelledByUser
        }
        if handleNFCError(error, session: session) {
            return operationError ?? error
        }
        if let digiDocError = error as? DigiDocError {
            handleDigiDocError(digiDocError, session: session)
            return digiDocError
        }
        handleUnknownError(error, session: session)
        return error
    }

    private var tagContinuation: CheckedContinuation<[NFCTag], Error>?

    func waitForTag() async throws -> [NFCTag] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[NFCTag], Error>) in
            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }
            tagContinuation = continuation
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: DispatchQueue.main)
            updateAlertMessage(step: 0)
            session?.begin()
        }
    }

    func withCardCommands<T>(
        canNumber: String,
        strings: NFCSessionStrings,
        _ body: (any CardCommands) async throws -> T
    ) async throws -> T {
        self.strings = strings
        return try await withTaskCancellationHandler {
            do {
                try Task.checkCancellation()
                let tags = try await waitForTag()
                guard let session else {
                    Self.logger().error("Unable to get session")
                    throw IdCardInternalError.nfcNotSupported
                }
                updateAlertMessage(step: 1)
                let tag = try await connection.setup(session, tags: tags)
                updateAlertMessage(step: 2)
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: canNumber)
                let result = try await body(cardCommands)
                success()
                return result
            } catch {
                if Task.isCancelled {
                    throw IdCardInternalError.cancelledByUser
                }
                Self.logger().error("Unable to complete NFC operation: \(String(describing: error))")
                if let session {
                    throw handleSessionError(error, session: session)
                }
                throw error
            }
        } onCancel: {
            Task { @MainActor in
                self.session?.invalidate()
            }
        }
    }

    // MARK: - NFCTagReaderSessionDelegate

    public func tagReaderSessionDidBecomeActive(_: NFCTagReaderSession) { }

    public func tagReaderSession(_: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        tagContinuation?.resume(returning: tags)
        tagContinuation = nil
    }

    public func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Self.logger().info("NFC: Reader session finished with error: \(String(describing: error))")
        session = nil
        guard let tagContinuation else { return }
        self.tagContinuation = nil
        if let nfcError = error as? NFCReaderError,
           nfcError.code == .readerSessionInvalidationErrorUserCanceled {
            tagContinuation.resume(throwing: IdCardInternalError.cancelledByUser)
        } else {
            tagContinuation.resume(throwing: error)
        }
    }
}
