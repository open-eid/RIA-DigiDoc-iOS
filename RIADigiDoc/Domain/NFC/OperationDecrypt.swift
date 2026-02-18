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
import CommonCrypto
import CryptoTokenKit
internal import SwiftECC
import BigInt
import CryptoKit
import IdCardLib
import CryptoObjCWrapper
import CryptoSwift
import UtilsLib

@MainActor
public class OperationDecrypt: NFCOperationBase {
    private var containerFile: URL?
    private var recipients: [Addressee] = []
    private var pin1Number: SecureData = SecureData([0x00])
    private var continuation: CheckedContinuation<CryptoContainerProtocol, Error>?

    public func processDecrypt(
        canNumber: String,
        pin1Number: SecureData,
        containerFile: URL,
        recipients: [Addressee],
        strings: NFCSessionStrings,
    ) async throws -> CryptoContainerProtocol {

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }
            self.canNumber = canNumber
            self.pin1Number = pin1Number
            self.containerFile = containerFile
            self.recipients = recipients
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

            guard let containerFile else {
                let error = DecryptError.containerFileInvalid
                OperationDecrypt.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Failed to read container file")
                continuation?.resume(throwing: error)
                return
            }

            if containerFile.path.isEmpty {
                let error = DecryptError.containerFileInvalid
                OperationDecrypt.logger().error("NFC: Container file path is empty")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Failed to read container file")
                continuation?.resume(throwing: error)
                return
            }

            if recipients.isEmpty {
                let error = DecryptError.recipientsEmpty
                OperationDecrypt.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "No recipients found")
                continuation?.resume(throwing: error)
                return
            }

            OperationDecrypt.logger().info("NFC: Checks complete starting decryption")

            do {
                updateAlertMessage(step: 1)
                let tag = try await connection.setup(session, tags: tags)
                updateAlertMessage(step: 2)
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: canNumber)
                updateAlertMessage(step: 3)

                let (retryCount, _) = try await cardCommands.readCodeTryCounterRecord(.pin1)

                if retryCount == 0 {
                    throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
                }

                let cert = try await cardCommands.readAuthenticationCertificate()
                updateAlertMessage(step: 4)
                let decryptedContainer = try await CryptoContainer.decrypt(
                    containerFile: containerFile,
                    recipients: recipients,
                    cert: cert,
                    cardCommands: cardCommands,
                    pin: pin1Number,
                )
                continuation?.resume(with: .success(decryptedContainer))
                success()
            } catch {
                guard !checkIfFinished(error: error) else { return }

                if let idCardInternalError = error as? IdCardInternalError {
                    handleIdCardInternalError(idCardInternalError, session: session)
                    continuation?.resume(throwing: error)
                    return
                }

                if let decryptError = error as? DecryptError {
                    OperationDecrypt.logger()
                        .error("NFC: DecryptError: \(decryptError.localizedDescription)")
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ?? "")
                    continuation?.resume(throwing: error)
                    return
                }

                let wrappedError = DecryptError.unknown(handleUnknownError(error, session: session))
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
