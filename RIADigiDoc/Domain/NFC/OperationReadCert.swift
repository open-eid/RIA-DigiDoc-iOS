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
import nfclib
import UtilsLib

@MainActor
final public class OperationReadCert: NFCOperationBase, OperationReadCertProtocol {
    private var continuation: CheckedContinuation<String, Error>?
    private var returnData: String?

    public func startReading(
        canNumber: String,
        strings: NFCSessionStrings,
    ) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

            self.canNumber = canNumber
            self.strings = strings

            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            updateAlertMessage(step: 0)
            session?.begin()
        }
    }

    // MARK: - NFCTagReaderSessionDelegate

    public override func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Task {
            defer {
                self.session = nil
            }

            do {
                updateAlertMessage(step: 1)
                Self.logger().info("Setting up NFC connection...")
                let tag = try await connection.setup(session, tags: tags)

                updateAlertMessage(step: 2)
                Self.logger().info("Establishing secure channel with CAN...")
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: canNumber)

                updateAlertMessage(step: 3)

                Self.logger().info("Reading signature certificate")
                let signerCert = try await cardCommands.readSignatureCertificate()

                updateAlertMessage(step: 4)

                returnData = signerCert.base64EncodedString()

                success()
            } catch {
                if let idCardInternalError = error as? IdCardInternalError {
                    handleIdCardInternalError(idCardInternalError, session: session)
                    return
                }

                if let nfcIdCardError = error as? nfclib.IdCardInternalError {
                    handleIdCardInternalError(nfcIdCardError, session: session)
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

        if let returnData, didCompleteSuccessfully {
            continuationToResume.resume(with: .success(returnData))
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
