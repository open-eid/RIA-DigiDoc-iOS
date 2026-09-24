// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol WebEidViewModelProtocol: Sendable {
    func handleAuth(url: URL)
    func handleCertificate(url: URL)
    func handleSign(url: URL)
    func handleUnknown(url: URL)

    func handleWebEidAuthResult(
        authCert: Data,
        signingCert: Data,
        signature: Data
    ) async
    func handleWebEidCertificateResult(signingCert: Data) async
    func handleWebEidSignResult(
        signingCert: String,
        signature: Data,
        responseUri: String
    ) async

    func resetErrors()

    func isWebEidSessionActive() async -> Bool
    func setWebEidSessionActive(_ value: Bool) async
}
