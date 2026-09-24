// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
