// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol WebEidAuthServiceProtocol: Sendable {
    func buildAuthToken(
        authCert: Data,
        signingCert: Data?,
        signature: Data,
    ) async throws -> Data
}
