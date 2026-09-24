// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation
import nfclib
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol OperationWebEidAuthProtocol {
    // swiftlint:disable:next function_parameter_count
    func startOperation(
        canNumber: String,
        pin1Number: SecureData,
        origin: String,
        challenge: String,
        userAgent: String,
        strings: NFCSessionStrings
    ) async throws -> WebEidAuthReturnData
}
