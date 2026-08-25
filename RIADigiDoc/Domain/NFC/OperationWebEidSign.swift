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
import CommonsLib
import CryptoTokenKit
import Security
import nfclib
import LibdigidocLibSwift
import UtilsLib

public struct WebEidSignReturnData: Sendable {
    var signerCertB64: String
    var signatureArray: Data
    var responseUri: String
}

@MainActor
public class OperationWebEidSign: NFCOperationBase, OperationWebEidSignProtocol {
    private var pin2Number: SecureData = SecureData([0x00])
    private var responseUri: String = ""
    private var hashToSign: String = ""
    private var expectedSigningCertBase64: String?
    private var userAgent: String = ""
    private var returnData: WebEidSignReturnData?

    private var continuation: CheckedContinuation<WebEidSignReturnData, Error>?

    // swiftlint:disable:next function_parameter_count
    public func startOperation(
        canNumber: String,
        pin2Number: SecureData,
        responseUri: String,
        hash: String,
        expectedSigningCertBase64: String?,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> WebEidSignReturnData {

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

            guard let expectedCert = expectedSigningCertBase64,
                  !expectedCert.isEmpty,
                  Data(base64Encoded: expectedCert) != nil else {
                continuation.resume(throwing: ReadCertAndSignError.invalidCertificate)
                return
            }

            guard let hashBytes = Data(base64Encoded: hash), !hashBytes.isEmpty else {
                continuation.resume(throwing: ReadCertAndSignError.hashInvalid)
                return
            }

            self.canNumber = canNumber
            self.pin2Number = pin2Number
            self.responseUri = responseUri
            self.hashToSign = hash
            self.expectedSigningCertBase64 = expectedSigningCertBase64
            self.userAgent = userAgent
            self.strings = strings

            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            updateAlertMessage(step: 0)
            session?.begin()
        }
    }

    // MARK: - NFCTagReaderSessionDelegate

    // swiftlint:disable:next cyclomatic_complexity
    public override func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Task { @MainActor in
            defer {
                self.session = nil
            }

            if userAgent.isEmpty {
                let error = ReadCertAndSignError.userAgentEmpty
                Self.logger().error("NFC: \(error.localizedDescription)")
                operationError = error
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Failed to initialize user agent")
                return
            }

            Self.logger().info("NFC: Checks complete starting signing")

            do {
                updateAlertMessage(step: 1)
                let tag = try await connection.setup(session, tags: tags)

                updateAlertMessage(step: 2)
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: canNumber)

                updateAlertMessage(step: 3)

                let (retryCount, pinActive) = try await cardCommands.readCodeTryCounterRecord(.pin2)

                if retryCount == 0 {
                    throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
                }
                if !pinActive {
                    throw IdCardInternalError.pinLocked
                }

                let signerCert = try await cardCommands.readSignatureCertificate()

                guard let expectedSigningCertBase64,
                      !expectedSigningCertBase64.isEmpty,
                      let expectedCert = Data(base64Encoded: expectedSigningCertBase64) else {
                    let error = ReadCertAndSignError.invalidCertificate
                    Self.logger().error("NFC: \(error.localizedDescription)")
                    operationError = error
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                       "Missing Web eID signing certificate")
                    return
                }

                if expectedCert != signerCert {
                    let error = ReadCertAndSignError.certMismatch
                    Self.logger().error("NFC: \(error.localizedDescription)")
                    operationError = error
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                       "Web eID signing certificate mismatch")
                    return
                }

                let signerCertB64 = signerCert.base64EncodedString()

                guard let hashBytes = Data(base64Encoded: hashToSign), !hashBytes.isEmpty else {
                    let error = ReadCertAndSignError.hashInvalid
                    Self.logger().error("NFC: \(error.localizedDescription)")
                    operationError = error
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                       "Invalid hash encoding")
                    return
                }

                let signatureArray = try await cardCommands.calculateSignature(for: hashBytes, withPin2: pin2Number)

                updateAlertMessage(step: 4)
                returnData = WebEidSignReturnData(
                    signerCertB64: signerCertB64,
                    signatureArray: signatureArray,
                    responseUri: responseUri
                )

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

                if let readCertSignError = error as? ReadCertAndSignError {
                    Self.logger()
                        .error("NFC: ReadCertAndSignError: \(readCertSignError.localizedDescription)")
                    operationError = readCertSignError
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ?? "")
                    return
                }

                if let digiDocError = error as? DigiDocError {
                    handleDigiDocError(digiDocError, session: session)
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
