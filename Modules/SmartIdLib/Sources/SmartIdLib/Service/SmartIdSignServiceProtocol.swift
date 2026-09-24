// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

// swiftlint:disable function_parameter_count
/// @mockable
public protocol SmartIdSignServiceProtocol: Sendable {

    func getCertificateRequest(
        url: String,
        relyingPartyName: String,
        relyingPartyUUID: String,
        country: String,
        nationalIdentityNumber: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> SmartIdSessionIdResponse

    func getSignatureRequest(
        url: String,
        relyingPartyName: String,
        relyingPartyUUID: String,
        documentNumber: String,
        hash: Data,
        hashType: String,
        allowedInteractionsOrderType: String,
        displayText200: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> SmartIdSessionIdResponse

    func getSessionRequest(
        url: String,
        sessionId: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> SmartIdSessionResponse

    func getVerificationCode(digest: Data) async -> String
}
// swiftlint:enable function_parameter_count
