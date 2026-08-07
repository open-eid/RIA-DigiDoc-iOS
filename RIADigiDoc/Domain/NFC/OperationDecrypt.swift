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
            let (retryCount, _) = try await cardCommands.readCodeTryCounterRecord(.pin1)
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
