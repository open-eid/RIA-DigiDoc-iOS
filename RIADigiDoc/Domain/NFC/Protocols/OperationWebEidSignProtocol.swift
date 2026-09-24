// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import nfclib
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol OperationWebEidSignProtocol {
    // swiftlint:disable:next function_parameter_count
    func startOperation(
        canNumber: String,
        pin2Number: SecureData,
        responseUri: String,
        hash: String,
        expectedSigningCertBase64: String?,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> WebEidSignReturnData
}
