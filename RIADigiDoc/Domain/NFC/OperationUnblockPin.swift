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
import CommonCrypto
import CryptoTokenKit
import Security
import nfclib

@MainActor
public class OperationUnblockPin: NFCOperationBase, OperationUnblockPinProtocol {
    private var codeType: CodeType?
    private var puk: SecureData?
    private var newPin: SecureData?
    private var continuation: CheckedContinuation<Void, Error>?

    public func startReading(
        canNumber: String,
        codeType: CodeType,
        puk: SecureData,
        newPin: SecureData,
        strings: NFCSessionStrings
    ) async throws {
        self.canNumber = canNumber
        self.codeType = codeType
        self.puk = puk
        self.newPin = newPin
        self.strings = strings

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

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
                    let puk = self.puk,
                    let newPin = self.newPin else {
                let error = UnblockPINError.missingRequiredParameter
                operationError = error
                OperationUnblockPin.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Missing required parameters")
                return
            }
            do {
                updateAlertMessage(step: 1)
                let tag = try await self.connection.setup(session, tags: tags)

                updateAlertMessage(step: 2)
                let cardCommands = try await self.connection.getCardCommands(session, tag: tag, CAN: self.canNumber)

                updateAlertMessage(step: 3)
                try await cardCommands.unblockCode(codeType, puk: puk, newCode: newPin)

                success()
            } catch {
                if (error as NSError).localizedDescription == "Failed to find lock for cert" {
                    handleNoCertLockError(error: error, session: session)
                    return
                }

                if let idCardInternalError = error as? IdCardInternalError {
                    handleIdCardInternalError(idCardInternalError, session: session)
                    return
                }

                if let nfcIdCardError = error as? nfclib.IdCardInternalError {
                    handleIdCardInternalError(nfcIdCardError, session: session)
                    return
                }

                if let unblockPINError = error as? UnblockPINError {
                    operationError = unblockPINError
                    OperationReadCertAndSign.logger()
                        .error("NFC: UnblockPINError: \(unblockPINError.localizedDescription)")
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ?? "")
                    return
                }

                handleUnknownError(error, session: session)
            }
        }
    }

    public override func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Self.logger().info("NFC: Reader session finished with error: \(error)")
        self.session = nil

        guard let continuationToResume = self.continuation else { return }
        self.continuation = nil

        if didCompleteSuccessfully {
            continuationToResume.resume(with: .success(()))
            return
        }

        if let storedError = self.operationError {
            continuationToResume.resume(throwing: storedError)
            return
        }

        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                continuationToResume.resume(throwing: IdCardInternalError.cancelledByUser)
                return

            default:
                break
            }
        }

        continuationToResume.resume(throwing: error)
    }
}
