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
final public class OperationReadCardData: NFCOperationBase {
    private var continuation: CheckedContinuation<NFCCardData, Error>?

    public func startReading(
        canNumber: String,
        strings: NFCSessionStrings,
    ) async throws -> NFCCardData {
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
                OperationReadCardData.logger().info("Setting up NFC connection...")
                let tag = try await connection.setup(session, tags: tags)

                updateAlertMessage(step: 2)
                OperationReadCardData.logger().info("Establishing secure channel with CAN...")
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: canNumber)

                OperationReadCardData.logger().info("Reading public data...")
                let cardInfo = try await cardCommands.readPublicData()
                OperationReadCardData.logger().info("Public data read successfully")

                updateAlertMessage(step: 3)
                OperationReadCardData.logger().info("Reading authentication certificate")
                let authenticationCertificate = try await cardCommands.readAuthenticationCertificate()

                OperationReadCardData.logger().info("Reading signature certificate")
                let signatureCertificate = try await cardCommands.readSignatureCertificate()

                updateAlertMessage(step: 4)
                OperationReadCardData.logger().info("Reading PIN retry counts...")

                let pin1Response = try await cardCommands.readCodeTryCounterRecord(.pin1)
                OperationReadCardData.logger().info("PIN1 retry count: \(pin1Response.retryCount)")
                OperationReadCardData.logger().info("PIN1 active: \(pin1Response.pinActive)")
                let pin2Response = try await cardCommands.readCodeTryCounterRecord(.pin2)
                OperationReadCardData.logger().info("PIN2 retry count: \(pin2Response.retryCount)")
                OperationReadCardData.logger().info("PIN2 active: \(pin2Response.pinActive)")
                let pukResponse = try await cardCommands.readCodeTryCounterRecord(.puk)
                OperationReadCardData.logger().info("PUK retry count: \(pukResponse.retryCount)")
                OperationReadCardData.logger().info("PUK active: \(pukResponse.pinActive)")

                let pinResponse = PinResponse(
                    pin1RetryCount: pin1Response.retryCount,
                    pin1Active: pin1Response.pinActive,
                    pin2RetryCount: pin2Response.retryCount,
                    pin2Active: pin2Response.pinActive,
                    pukRetryCount: pukResponse.retryCount,
                    pukActive: pukResponse.pinActive,
                )

                OperationReadCardData.logger().info("NFC: reading can change PUK")
                let canChangePUK = cardCommands.canChangePUK
                OperationReadCardData.logger().info("NFC: can change PUK: \(canChangePUK)")

                let cardData = NFCCardData(
                    publicData: cardInfo,
                    authenticationCertificate: authenticationCertificate,
                    signatureCertificate: signatureCertificate,
                    pinResponse: pinResponse,
                    isPUKChangable: canChangePUK
                )

                continuation?.resume(with: .success(cardData))
                success()
            } catch {
                guard !checkIfFinished(error: error) else { return }

                if let idCardInternalError = error as? IdCardInternalError {
                    handleIdCardInternalError(idCardInternalError, session: session)
                    continuation?.resume(throwing: error)
                    return
                }

                let unknownError = handleUnknownError(error, session: session)
                continuation?.resume(throwing: unknownError)
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
