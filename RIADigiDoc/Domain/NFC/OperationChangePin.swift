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
import UtilsLib
import IdCardLib

@MainActor
public class OperationChangePin: NFCOperationBase {
    private var codeType: CodeType?
    private var currentPin: SecureData?
    private var newPin: SecureData?
    private var continuation: CheckedContinuation<Void, Error>?

    public func startChanging(
        canNumber: String,
        codeType: CodeType,
        currentPin: SecureData,
        newPin: SecureData,
        strings: NFCSessionStrings,
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

            self.canNumber = canNumber
            self.codeType = codeType
            self.currentPin = currentPin
            self.newPin = newPin
            self.strings = strings
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            updateAlertMessage(step: 0)
            session?.begin()
        }
    }

    // MARK: - NFCTagReaderSessionDelegate

    public override func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Task { @MainActor in
            defer {
                self.session = nil
            }

            guard let codeType = self.codeType,
                  let currentPin = self.currentPin,
                  let newPin = self.newPin else {
                let error = ChangePinError.missingRequiredParameter
                OperationChangePin.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Missing required parameters")
                continuation?.resume(throwing: error)
                return
            }

            do {
                updateAlertMessage(step: 1)
                OperationChangePin.logger().info("NFC: Setting up NFC connection for PIN change...")
                let tag = try await self.connection.setup(session, tags: tags)

                updateAlertMessage(step: 2)
                let cardCommands = try await self.connection.getCardCommands(session, tag: tag, CAN: self.canNumber)

                updateAlertMessage(step: 3)
                OperationChangePin.logger().info("NFC: Changing \(codeType.name)...")
                try await cardCommands.changeCode(codeType, to: newPin, verifyCode: currentPin)
                OperationChangePin.logger().info("NFC: \(codeType.name) changed successfully")

                self.continuation?.resume(with: .success(()))
                success()
            } catch {
                guard !checkIfFinished(error: error) else { return }

                if let idCardInternalError = error as? IdCardInternalError {
                    handleIdCardInternalError(idCardInternalError, session: session)
                    continuation?.resume(throwing: error)
                    return
                }

                if let changePinError = error as? ChangePinError {
                    OperationChangePin.logger()
                        .error("NFC: changePinError: \(changePinError.localizedDescription)")
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ?? "")
                    continuation?.resume(throwing: error)
                    return
                }

                let wrappedError = UnblockPINError.unknown(handleUnknownError(error, session: session))
                continuation?.resume(throwing: wrappedError)
            }
        }
    }

    public override func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError error: Error) {
        self.session = nil
        guard !isFinished else { return }
        isFinished = true
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                continuation?.resume(throwing: IdCardInternalError.cancelledByUser)
                return

            default:
                break
            }
        }
        continuation?.resume(throwing: error)
    }

}
