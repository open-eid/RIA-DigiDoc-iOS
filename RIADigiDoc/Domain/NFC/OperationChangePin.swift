// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CoreNFC
import UtilsLib
import nfclib

@MainActor
public class OperationChangePin: NFCOperationBase, OperationChangePinProtocol {
    public func startChanging(
        canNumber: String,
        codeType: CodeType,
        currentPin: SecureData,
        newPin: SecureData,
        strings: NFCSessionStrings,
    ) async throws {
        defer {
            currentPin.secureZero()
            newPin.secureZero()
        }

        try await withCardCommands(canNumber: canNumber, strings: strings) { cardCommands in
            updateAlertMessage(step: 3)
            try await cardCommands.changeCode(codeType, to: newPin, verifyCode: currentPin)
        }
    }
}
