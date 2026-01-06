/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
        proxyInfo: ProxyInfo
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
        proxyInfo: ProxyInfo
    ) async throws -> MobileIdSignatureResponse

    func getSessionRequest(
        url: String,
        sessionId: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo
    ) async throws -> MobileIdSessionResponse

    func getVerificationCode(hash: Data) async -> String?
}
// swiftlint:enable function_parameter_count
