// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CoreNFC
import CommonCrypto
import CryptoTokenKit
import CryptoKit
import nfclib
import CryptoObjCWrapper
import CryptoSwift
import UtilsLib

@MainActor
public class OperationDecrypt: NFCOperationBase, OperationDecryptProtocol {
    public func processDecrypt(
        canNumber: String,
        pin1Number: SecureData,
        containerFile: URL,
        recipients: [Addressee],
        strings: NFCSessionStrings,
    ) async throws -> CryptoContainerProtocol {
        defer {
            pin1Number.secureZero()
        }

        guard !containerFile.path.isEmpty else {
            OperationDecrypt.logger().error("NFC: Container file path is empty")
            throw DecryptError.containerFileInvalid
        }
        guard !recipients.isEmpty else {
            OperationDecrypt.logger().error("NFC: \(DecryptError.recipientsEmpty.localizedDescription)")
            throw DecryptError.recipientsEmpty
        }

        return try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            updateAlertMessage(step: 3)
            let (retryCount, pin1Active) = try await cardCommands.readCodeTryCounterRecord(.pin1)
            if !pin1Active {
                throw IdCardInternalError.notActivated
            }
            if retryCount == 0 {
                throw IdCardInternalError.remainingPinRetryCount(Int(retryCount))
            }

            let cert = try await cardCommands.readAuthenticationCertificate()
            updateAlertMessage(step: 4)
            return try await CryptoContainer.decrypt(
                containerFile: containerFile,
                recipients: recipients,
                cert: cert,
                cardCommands: cardCommands,
                pin: pin1Number,
            )
        }
    }
}
