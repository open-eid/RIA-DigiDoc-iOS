// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import nfclib

/// @mockable
@MainActor
public protocol OperationUnblockPinProtocol {
    func startReading(
        canNumber: String,
        codeType: CodeType,
        puk: SecureData,
        newPin: SecureData,
        strings: NFCSessionStrings
    ) async throws
}
