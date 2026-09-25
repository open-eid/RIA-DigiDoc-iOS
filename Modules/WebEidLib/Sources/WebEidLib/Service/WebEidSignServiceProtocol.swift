// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol WebEidSignServiceProtocol: Sendable {
    func buildCertificatePayload(signingCert: Data) async throws -> Data

    func buildSignPayload(
        signingCert: String,
        signature: Data,
        hashFunction: String,
    ) async throws -> Data
}
