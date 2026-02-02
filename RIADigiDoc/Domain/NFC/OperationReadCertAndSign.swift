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
public class OperationReadCertAndSign: NSObject, Loggable {
    private var session: NFCTagReaderSession?
    private var isFinished = false
    private var canNumber: String = ""
    private var pin2Number: SecureData = SecureData([0x00])
    private var signedContainer: SignedContainerProtocol?
    private var containerPath: URL?
    private var roleData: RoleData?
    private var userAgent: String = ""
    private var nfcError: String? = ""
    private var strings: NFCSessionStrings?

    private let connection = NFCConnection()

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

    private func updateAlertMessage(step: Int) {
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
        OperationReadCertAndSign.logger().info("NFC: Updating alert message to: \(message)")
        message += "\n\n\(progressBar.generate())"
        session?.alertMessage = message
    }

    private func success() {
        session?.alertMessage = strings?.successMessage ?? ""
        session?.invalidate()
    }

    private func handleIdCardError(_ error: IdCardError) {
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
}

extension OperationReadCertAndSign: @MainActor NFCTagReaderSessionDelegate {
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Task { @MainActor in
            defer {
                self.session = nil
            }

            guard let signedContainer else {
                let error = ReadCertAndSignError.signedContainerNil
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Failed to read container data")
                continuation?.resume(throwing: error)
                return
            }
            guard let roleData else {
                let error = ReadCertAndSignError.roleDataNil
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Failed to read role data")
                continuation?.resume(throwing: error)
                return
            }
            guard let containerPath else {
                let error = ReadCertAndSignError.containerPathNil
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Failed to read container path")
                continuation?.resume(throwing: error)
                return
            }
            if userAgent.isEmpty {
                let error = ReadCertAndSignError.userAgentEmpty
                OperationReadCertAndSign.logger().error("NFC: \(error.localizedDescription)")
                session.invalidate(errorMessage: "Failed to initialize user agent")
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
                guard !isFinished else {
                    OperationReadCertAndSign.logger()
                        .info("NFC: Operation already finished, ignoring error: \(error.localizedDescription)")
                    return
                }
                isFinished = true

                if let idCardInternalError = error as? IdCardInternalError {
                    let idCardError = idCardInternalError.getIdCardError()
                    OperationReadCertAndSign.logger().error("NFC: IdCardError detected: \(idCardError)")
                    handleIdCardError(idCardError)
                    session.invalidate(errorMessage: nfcError ?? "")
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

                OperationReadCertAndSign.logger().error("NFC: Unknown error type: \(type(of: error))")
                OperationReadCertAndSign.logger().error("NFC: Error details: \(error.localizedDescription)")
                let wrappedError = ReadCertAndSignError.unknown(error)
                session.invalidate(errorMessage: strings?.sessionErrorMessage ?? "")
                continuation?.resume(throwing: wrappedError)
            }
        }
    }

    public func tagReaderSessionDidBecomeActive(_: NFCTagReaderSession) { }

    public func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError error: Error) {
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
