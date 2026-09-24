// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoObjCWrapper
import CryptoSwift
import Foundation
import nfclib

/// @mockable
@MainActor
public protocol OperationDecryptProtocol {
    func processDecrypt(
        canNumber: String,
        pin1Number: SecureData,
        containerFile: URL,
        recipients: [Addressee],
        strings: NFCSessionStrings,
    ) async throws -> CryptoContainerProtocol
}
