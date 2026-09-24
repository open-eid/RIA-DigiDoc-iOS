// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

// swiftlint:disable function_parameter_count
/// @mockable
public protocol MobileIdSignServiceProtocol: Sendable {

    func getCertificateRequest(
        url: String,
        relyingPartyName: String,
        relyingPartyUUID: String,
        phoneNumber: String,
        nationalIdentityNumber: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> MobileIdCertificateResponse

    func getSignatureRequest(
        url: String,
        relyingPartyName: String,
        relyingPartyUUID: String,
        phoneNumber: String,
        nationalIdentityNumber: String,
        hash: Data,
        hashType: String,
        language: String,
        displayText: String,
        displayTextFormat: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> MobileIdSignatureResponse

    func getSessionRequest(
        url: String,
        sessionId: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> MobileIdSessionResponse

    func getVerificationCode(hash: Data) async -> String?
}
// swiftlint:enable function_parameter_count
