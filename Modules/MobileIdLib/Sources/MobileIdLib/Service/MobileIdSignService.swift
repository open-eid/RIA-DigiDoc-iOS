/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
import Alamofire
import CommonsLib
import UtilsLib

actor MobileIdSignService: MobileIdSignServiceProtocol, Loggable {

    private let requestPerformer: RequestPerfomerProtocol
    private var session: Session?
    private var currentProxy: ProxyInfo?

    init(
        requestPerfomer: RequestPerfomerProtocol
    ) {
        self.requestPerformer = requestPerfomer
    }

    // swiftlint:disable:next function_parameter_count
    public func getCertificateRequest(
        url: String,
        relyingPartyName: String,
        relyingPartyUUID: String,
        phoneNumber: String,
        nationalIdentityNumber: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> MobileIdCertificateResponse {
        let request = MobileIdCertificateRequest(
            relyingPartyName: relyingPartyName,
            relyingPartyUUID: relyingPartyUUID,
            phoneNumber: "+\(phoneNumber)",
            nationalIdentityNumber: nationalIdentityNumber
        )

        return try await requestPerformer.performRequest(
            url: url,
            method: .post,
            parameters: request,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )
    }

    // swiftlint:disable:next function_parameter_count
    public func getSignatureRequest(
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
    ) async throws -> MobileIdSignatureResponse {
        let request = MobileIdSignatureRequest(
            certificateRequest: .init(
                relyingPartyName: relyingPartyName,
                relyingPartyUUID: relyingPartyUUID,
                phoneNumber: "+\(phoneNumber)",
                nationalIdentityNumber: nationalIdentityNumber
            ),
            hash: hash.base64EncodedString(),
            hashType: hashType,
            language: language,
            displayText: displayText,
            displayTextFormat: displayTextFormat
        )

        return try await requestPerformer.performRequest(
            url: url,
            method: .post,
            parameters: request,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )
    }

    // swiftlint:disable:next function_parameter_count
    public func getSessionRequest(
        url: String,
        sessionId: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> MobileIdSessionResponse {
        let pollingTimeoutMs = pollingTimeout * 1000

        while true {
            let sessionResponse: MobileIdSessionResponse? = try await requestPerformer.performRequest(
                url: "\(url)/\(sessionId)",
                method: .get,
                parameters: ["timeoutMs": pollingTimeoutMs],
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )

            if let response = sessionResponse,
               response.state == .complete {
                return response
            }

            try await Task.sleep(for: .seconds(Double(pollingTimeout)))
        }
    }

    public func getVerificationCode(hash: Data) async -> String? {
        guard let first = hash.first, let last = hash.last else { return nil }
        let code = ((0xFC & Int(first)) << 5) | (Int(last) & 0x7F)
        return String(format: "%04d", code)
    }
}
