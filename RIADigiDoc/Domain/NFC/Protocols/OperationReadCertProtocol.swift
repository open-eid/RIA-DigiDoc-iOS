// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

/// @mockable
@MainActor
public protocol OperationReadCertProtocol {
    func startReading(
        canNumber: String,
        strings: NFCSessionStrings,
    ) async throws -> String
}
