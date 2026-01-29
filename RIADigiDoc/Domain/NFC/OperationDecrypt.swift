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
import SwiftUI

@MainActor
public class OperationDecrypt: NSObject {

    private var session: NFCTagReaderSession?
    private var containerFile: URL = URL(fileURLWithPath: "")
    private var recipients: [Addressee] = []
    private var CAN: String = ""
    private var PIN: SecureData = SecureData([0x00])
    private var continuation: CheckedContinuation<CryptoContainerProtocol, Error>?
    private var connection = NFCConnection()

    private var nfcErrorKey: String?
    private var nfcErrorExtraArguments: [String] = []

    private let languageSettings: LanguageSettings

    public init(languageSettings: LanguageSettings) {
        self.languageSettings = languageSettings
        super.init()
    }

    public func processDecrypt(
        CAN: String,
        PIN1: SecureData,
        containerFile: URL,
        recipients: [Addressee]
    ) async throws -> CryptoContainerProtocol {

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }
            self.CAN = CAN
            self.PIN = PIN1
            self.containerFile = containerFile
            self.recipients = recipients

            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            updateAlertMessage(step: 0)
            session?.begin()
        }
    }

    private func updateAlertMessage(step: Int) {
        let stepMessages = [
            "Please place your ID card against the smart device",
            "Hold your ID card against your smart device until the data is read",
            "Reading data please wait",
            "Reading certificate please wait",
            "Decrypting in progress please wait"
        ]

        let stepMessage = stepMessages[min(step, stepMessages.count - 1)]
        let progressBar = ProgressBar(currentStep: step)
        var message = languageSettings.localized(stepMessage)
        message += "\n\n\(progressBar.generate())"
        session?.alertMessage = message
    }

    private func handleIdCardError(_ error: IdCardError, pinType: CodeType) {
        NFCViewModel.logger().error("NFC: ID Card error: \(error)")

        switch error {
        case .wrongCAN:
            nfcErrorKey = "Wrong CAN"
            nfcErrorExtraArguments = []
        case .wrongPIN(let triesLeft):
            if triesLeft > 1 {
                nfcErrorKey = "PIN verification error multiple"
                nfcErrorExtraArguments = [pinType.name, String(triesLeft)]
            } else if triesLeft == 1 {
                nfcErrorKey = "PIN verification error one"
                nfcErrorExtraArguments = [pinType.name]
            } else {
                nfcErrorKey = "PIN blocked"
                nfcErrorExtraArguments = [pinType.name]
            }
        case .sessionError:
            nfcErrorKey = "NFC session error"
            nfcErrorExtraArguments = []
        default:
            nfcErrorKey = "NFC technical error"
            nfcErrorExtraArguments = []
        }
    }
}

extension OperationDecrypt: @MainActor NFCTagReaderSessionDelegate {
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {

        Task { @MainActor in
            do {
                updateAlertMessage(step: 1)
                let tag = try await connection.setup(session, tags: tags)
                updateAlertMessage(step: 2)
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: CAN)
                updateAlertMessage(step: 3)
                let cert = try await cardCommands.readAuthenticationCertificate()
                updateAlertMessage(step: 4)
                let decryptedContainer = try await CryptoContainer.decrypt(
                    containerFile: containerFile,
                    recipients: recipients,
                    cert: cert,
                    cardCommands: cardCommands,
                    pin: PIN,
                )
                continuation?.resume(with: .success(decryptedContainer))
                session.alertMessage = languageSettings.localized("Data read")
                session.invalidate()
            } catch {
                guard let exception = error as? IdCardInternalError else {
                    nfcErrorKey = "NFC technical error"
                    nfcErrorExtraArguments = []
                    session.invalidate(errorMessage: languageSettings.localized(
                        nfcErrorKey ?? "",
                        nfcErrorExtraArguments
                    ))
                    continuation?.resume(throwing: error)
                    return
                }

                let idCardError  = exception.getIdCardError()
                handleIdCardError(idCardError, pinType: CodeType.pin1)

                session.invalidate(errorMessage: languageSettings.localized(
                    nfcErrorKey ?? "",
                    nfcErrorExtraArguments
                ))
                continuation?.resume(throwing: error)
            }
        }
    }

    public func tagReaderSessionDidBecomeActive(_: NFCTagReaderSession) { }

    public func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError _: Error) {
        self.session = nil
    }
}
