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
import CryptoKit
import CryptoTokenKit
import Security
import nfclib
import LibdigidocLibSwift
import UtilsLib

public struct WebEidAuthReturnData: Sendable {
    var authCert: Data
    var signingCert: Data
    var signatureArray: Data
}

@MainActor
public class OperationWebEidAuth: NFCOperationBase, OperationWebEidAuthProtocol {
    private var pin1Number: SecureData = SecureData([0x00])
    private var origin: String = ""
    private var challenge: String = ""
    private var userAgent: String = ""
    private var returnData: WebEidAuthReturnData?

    private var continuation: CheckedContinuation<WebEidAuthReturnData, Error>?

    // swiftlint:disable:next function_parameter_count
    public func startOperation(
        canNumber: String,
        pin1Number: SecureData,
        origin: String,
        challenge: String,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> WebEidAuthReturnData {

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

            self.canNumber = canNumber
            self.pin1Number = pin1Number
            self.origin = origin
            self.challenge = challenge
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

            Self.logger().info("NFC: Checks complete starting authentication")

            do {
                updateAlertMessage(step: 1)
                let tag = try await connection.setup(session, tags: tags)

                updateAlertMessage(step: 2)
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: canNumber)

                updateAlertMessage(step: 3)

                let (retryCount, pinActive) = try await cardCommands.readCodeTryCounterRecord(.pin1)

                if retryCount == 0 {
                    throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
                }
                if !pinActive {
                    throw IdCardInternalError.pinLocked
                }
                let authCert = try await cardCommands.readAuthenticationCertificate()
                let signerCert = try await cardCommands.readSignatureCertificate()

                guard let certificate = SecCertificateCreateWithData(nil, authCert as CFData) else {
                    let error = ReadCertAndSignError.invalidCertificate
                    Self.logger().error("NFC: \(error.localizedDescription)")
                    operationError = error
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                       "Invalid certificate")
                    return
                }

                guard let publicKey = SecCertificateCopyKey(certificate) else {
                    let error = ReadCertAndSignError.missingPublicKey
                    Self.logger().error("NFC: \(error.localizedDescription)")
                    operationError = error
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                       "Missing public key")
                    return
                }

                updateAlertMessage(step: 4)

                guard let hashAlgorithm = try resolveHashAlgorithm(from: publicKey) else {
                    let error = ReadCertAndSignError.missingPublicKey
                    Self.logger().error("NFC: \(error.localizedDescription)")
                    operationError = error
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                       "Unsupported algorithm")

                    return
                }

                let originHash = digest(Data(origin.utf8), using: hashAlgorithm)
                let challengeHash = digest(Data(challenge.utf8), using: hashAlgorithm)

                let signedData = originHash + challengeHash
                let tbsHash = digest(signedData, using: hashAlgorithm)

                let signatureArray = try await cardCommands.authenticate(for: tbsHash, withPin1: pin1Number)

                returnData = WebEidAuthReturnData(
                    authCert: authCert,
                    signingCert: signerCert,
                    signatureArray: signatureArray
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

    // MARK: - Helpers
    private func resolveHashAlgorithm(from publicKey: SecKey) throws -> HashAlgorithm? {
        guard let attrs = SecKeyCopyAttributes(publicKey) as? [CFString: Any],
              let keyType = attrs[kSecAttrKeyType] as? String,
              let keySizeBits = attrs[kSecAttrKeySizeInBits] as? Int else {
            return nil
        }

        guard keyType == (kSecAttrKeyTypeECSECPrimeRandom as String) else {
            return nil
        }

        switch keySizeBits {
        case 256: return .sha256
        case 384: return .sha384
        case 521: return .sha512
        default:
            return nil
        }
    }

    private enum HashAlgorithm {
        case sha256
        case sha384
        case sha512
    }

    private func digest(_ data: Data, using algorithm: HashAlgorithm) -> Data {
        switch algorithm {
        case .sha256:
            return Data(SHA256.hash(data: data))
        case .sha384:
            return Data(SHA384.hash(data: data))
        case .sha512:
            return Data(SHA512.hash(data: data))
        }
    }
}
