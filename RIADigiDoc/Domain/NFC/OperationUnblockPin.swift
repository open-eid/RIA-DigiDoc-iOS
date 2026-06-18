// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CoreNFC
import CommonCrypto
import CryptoTokenKit
import Security
import nfclib

@MainActor
public class OperationUnblockPin: NFCOperationBase, OperationUnblockPinProtocol {
    public func startReading(
        canNumber: String,
        codeType: CodeType,
        puk: SecureData,
        newPin: SecureData,
        strings: NFCSessionStrings
    ) async throws {
        defer {
            puk.secureZero()
            newPin.secureZero()
        }

        try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            updateAlertMessage(step: 3)
            try await cardCommands.unblockCode(codeType, puk: puk, newCode: newPin)
        }
    }
}
