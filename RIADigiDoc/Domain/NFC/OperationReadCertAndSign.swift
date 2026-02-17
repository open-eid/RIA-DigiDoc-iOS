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
internal import SwiftECC
import BigInt
import Security
import IdCardLib
import LibdigidocLibSwift
import UtilsLib

@MainActor
public class OperationReadCertAndSign: NFCOperationBase {
    private var pin2Number: SecureData = SecureData([0x00])
    private var signedContainer: SignedContainerProtocol?
    private var containerPath: URL?
    private var roleData: RoleData?
    private var userAgent: String = ""

    private var continuation: CheckedContinuation<SignedContainerProtocol, Error>?

    // swiftlint:disable:next function_parameter_count
    public func startOperation(
        canNumber: String,
        pin2Number: SecureData,
        signedContainer: SignedContainerProtocol,
        containerPath: URL,
        roleData: RoleData,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> SignedContainerProtocol {

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

            self.canNumber = canNumber
            self.pin2Number = pin2Number
            self.signedContainer = signedContainer
            self.containerPath = containerPath
            self.roleData = roleData
            self.userAgent = userAgent
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

            guard let signedContainer else {
                let error = ReadCertAndSignError.signedContainerNil
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Failed to read container data")
                continuation?.resume(throwing: error)
                return
            }
            guard let roleData else {
                let error = ReadCertAndSignError.roleDataNil
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Failed to read role data")
                continuation?.resume(throwing: error)
                return
            }
            guard let containerPath else {
                let error = ReadCertAndSignError.containerPathNil
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Failed to read container path")
                continuation?.resume(throwing: error)
                return
            }
            if userAgent.isEmpty {
                let error = ReadCertAndSignError.userAgentEmpty
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: strings?.technicalErrorMessage ??
                                   "Failed to initialize user agent")
                continuation?.resume(throwing: error)
                return
            }

            OperationReadCertAndSign.logger().info("NFC: Checks complete starting signing")

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
                
                let cert = try await cardCommands.readSignatureCertificate()
                let hashToSign = try await signedContainer.prepareSignature(
                    cert: cert,
                    containerPath: containerPath,
                    roleData: roleData,
                    userAgent: userAgent
                )

                let signatureValue = try await cardCommands.calculateSignature(for: hashToSign, withPin2: pin2Number)

                updateAlertMessage(step: 4)
                let result = try await signedContainer.addSignature(
                    signature: signatureValue,
                    containerFile: containerPath
                )

                continuation?.resume(with: .success(result))
                success()
            } catch {
                guard !checkIfFinished(error: error) else { return }

                if let idCardInternalError = error as? IdCardInternalError {
                    handleIdCardInternalError(idCardInternalError, session: session)
                    continuation?.resume(throwing: error)
                    return
                }

                if let readCertSignError = error as? ReadCertAndSignError {
                    OperationReadCertAndSign.logger()
                        .error("NFC: ReadCertAndSignError: \(readCertSignError.localizedDescription)")
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ?? "")
                    continuation?.resume(throwing: error)
                    return
                }

                if let digiDocError = error as? DigiDocError {
                    OperationReadCertAndSign.logger().error("NFC: DigidocError: \(digiDocError.localizedDescription)")
                    session.invalidate(errorMessage: strings?.technicalErrorMessage ?? "")
                    continuation?.resume(throwing: error)
                    return
                }

                let wrappedError = ReadCertAndSignError.unknown(handleUnknownError(error, session: session))
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
