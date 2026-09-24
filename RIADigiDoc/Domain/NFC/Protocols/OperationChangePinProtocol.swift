// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import nfclib

/// @mockable
@MainActor
public protocol OperationChangePinProtocol {
    func startChanging(
        canNumber: String,
        codeType: CodeType,
        currentPin: SecureData,
        newPin: SecureData,
        strings: NFCSessionStrings,
    ) async throws
}
