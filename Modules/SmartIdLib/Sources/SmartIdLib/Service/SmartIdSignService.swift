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
import UIKit

public actor SmartIdSignService: SmartIdSignServiceProtocol, Loggable {

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
        country: String,
        nationalIdentityNumber: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> SmartIdSessionIdResponse {
        let request = SmartIdCertificateRequest(
            relyingPartyName: relyingPartyName,
            relyingPartyUUID: relyingPartyUUID
        )

        let semanticsIdentifier = "PNO\(country)-\(nationalIdentityNumber)"

        return try await requestPerformer.performRequest(
            url: "\(url)/\(semanticsIdentifier)",
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
        documentNumber: String,
        hash: Data,
        hashType: String,
        allowedInteractionsOrderType: String,
        displayText200: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> SmartIdSessionIdResponse {
        let request = SmartIdSignatureRequest(
            relyingPartyName: relyingPartyName,
            relyingPartyUUID: relyingPartyUUID,
            hash: hash.base64EncodedString(),
            hashType: hashType,
            allowedInteractionsOrder: [AllowedInteractionsOrder(
                type: allowedInteractionsOrderType,
                displayText200: displayText200
            )]
        )

        return try await requestPerformer.performRequest(
            url: "\(url)/\(documentNumber)",
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
    ) async throws -> SmartIdSessionResponse {
        let pollingTimeoutMs = pollingTimeout * 1000

        while true {
            let sessionResponse: SmartIdSessionResponse? = try await requestPerformer.performRequest(
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

    public func getVerificationCode(digest: Data) async -> String {
        let code = UInt16(digest[digest.count - 2]) << 8 | UInt16(digest[digest.count - 1])
        return String(format: "%04d", (code % 10000))
    }
}
