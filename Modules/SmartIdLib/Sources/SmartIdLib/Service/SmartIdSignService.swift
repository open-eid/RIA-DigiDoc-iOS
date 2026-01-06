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
import OSLog
import Alamofire
import CommonsLib
import UtilsLib
import UIKit

public actor SmartIdSignService: SmartIdSignServiceProtocol {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc",
        category: "SmartIdSignService"
    )

    private var session: Session?
    private var currentProxy: ProxyInfo?

    // swiftlint:disable:next function_parameter_count
    public func getCertificateRequest(
        url: String,
        relyingPartyName: String,
        relyingPartyUUID: String,
        country: String,
        nationalIdentityNumber: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo
    ) async throws -> SmartIdSessionIdResponse {
        let request = SmartIdCertificateRequest(
            relyingPartyName: relyingPartyName,
            relyingPartyUUID: relyingPartyUUID
        )

        let semanticsIdentifier = "PNO\(country)-\(nationalIdentityNumber)"

        return try await performRequest(
            url: "\(url)/\(semanticsIdentifier)",
            method: .post,
            parameters: request,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo
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
        proxyInfo: ProxyInfo
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

        return try await performRequest(
            url: "\(url)/\(documentNumber)",
            method: .post,
            parameters: request,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo
        )
    }

    public func getSessionRequest(
        url: String,
        sessionId: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo
    ) async throws -> SmartIdSessionResponse {
        let pollingTimeoutMs = pollingTimeout * 1000

        while true {
            let sessionResponse: SmartIdSessionResponse? = try await performRequest(
                url: "\(url)/\(sessionId)",
                method: .get,
                parameters: ["timeoutMs": pollingTimeoutMs],
                trustedCertificates: trustedCertificates,
                proxyInfo: proxyInfo
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

    func performRequest<T: Decodable & Sendable, P: Encodable & Sendable>(
        url: String,
        method: HTTPMethod,
        parameters: P? = nil,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let encoder: ParameterEncoder = method == .get ?
                    URLEncodedFormParameterEncoder.default :
                    JSONParameterEncoder.default

                    let session = try await ensureSession(
                        url: url,
                        trustedCertificates: trustedCertificates,
                        proxyInfo: proxyInfo
                    )
                    let headers = SmartIdSignService.defaultHeaders()

                    let response = await session.request(
                        url,
                        method: method,
                        parameters: parameters,
                        encoder: encoder,
                        headers: headers
                    )
                        .validate()
                        .serializingDecodable(T.self)
                        .response

                    switch response.result {
                    case .success(let value):
                        if let response = value as? SmartIdSessionResponse, let result = response.result?.endResult {
                            do {
                                try handleSessionResult(result)
                            } catch {
                                continuation.resume(throwing: error)
                                return
                            }
                        }
                        continuation.resume(returning: value)
                        return
                    case .failure(let afError):
                        continuation.resume(with: Result {
                            try handleCancellationError(afError)
                            try handleNetworkError(afError, statusCode: response.response?.statusCode)

                            throw SmartIdError.generalError
                        })
                        return
                    }

                } catch {
                    Task { @MainActor in
                        continuation.resume(throwing: SmartIdError.timeout)
                        return
                    }

                    continuation.resume(with: Result {
                        try handleCancellationError(error)
                        guard let smartIdError = error as? SmartIdError else {
                            throw SmartIdError.generalError
                        }
                        throw smartIdError
                    })
                    return
                }
            }
        }
    }

    private static func defaultHeaders() -> HTTPHeaders {
        [
            .contentType("application/json; charset=utf-8"),
            .init(name: "Cache-Control", value: "no-cache"),
            .init(name: "Pragma", value: "no-cache")
        ]
    }

    private func ensureSession(
        url: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo
    ) async throws -> Session {
        if currentProxy == proxyInfo {
            if let existing = session { return existing }
        }

        currentProxy = proxyInfo

        guard let host = URL(string: url)?.host else {
            SmartIdSignService.logger.error(
                "Unable to parse host from URL: \(url)"
            )
            throw URLError(.badURL)
        }

        let newSession = SmartIdSignService.createAlamofireSession(
            host: host,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo
        )

        session = newSession
        return newSession
    }

    private static func createAlamofireSession(
        host: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo
    ) -> Session {
        let evaluators = [host: PinnedCertificatesTrustEvaluator(certificates: trustedCertificates)]

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(Constants.Signing.Timeout)
        config.timeoutIntervalForResource = TimeInterval(Constants.Signing.Timeout)
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil

        return Session.withProxy(
            proxyInfo: proxyInfo,
            configuration: config,
            serverTrustManager: ServerTrustManager(evaluators: evaluators)
        )
    }

    private func handleSessionResponse(_ responseValue: Any) throws {
        if let sessionResponse = responseValue as? SmartIdSessionResponse {
            guard sessionResponse.state == .complete else { return }

            guard let endResult = sessionResponse.result?.endResult else { return }

            try handleSessionResult(endResult)
        }
    }

    private func handleSessionResult(_ response: SmartIdSessionStatusResponseCode) throws {
        switch response {
        case .timeout: throw SmartIdError.timeout
        case .userRefused,
                .userRefusedDisplayTextAndPin,
                .userRefusedVcChoice,
                .userRefusedConfirmationMessage,
                .userRefusedConfirmationMessageWithVcChoice,
                .userRefusedCertChoice:
            throw SmartIdError.userRefused
        case .wrongVc: throw SmartIdError.wrongVC
        case .documentUnusable: throw SmartIdError.documentUnusable
        case .requiredInteractionNotSupportedByApp: throw SmartIdError.oldApi
        default: break
        }
    }

    private func handleCancellationError(_ error: Error) throws {
        if let afError = error as? AFError {
            switch afError {
            case .explicitlyCancelled:
                throw SmartIdError.explicitlyCancelled
            default:
                return
            }
        }
    }

    private func handleNetworkError(_ error: AFError, statusCode: Int?) throws {
        if let underlyingError = error.underlyingError as? URLError {
            try handleURLError(underlyingError)
        } else {
            try handleStatusCodeError(statusCode)
        }
    }

    private func handleURLError(_ error: URLError) throws {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            throw SmartIdError.noInternetConnection
        case .timedOut:
            throw SmartIdError.timeout
        default:
            throw SmartIdError.noInternetConnection
        }
    }

    private func handleStatusCodeError(_ statusCode: Int?) throws {
        switch statusCode ?? -1 {
        case 400:
            throw SmartIdError.incorrectParameters
        case 401:
            throw SmartIdError.invalidAccessRights
        case 409:
            throw SmartIdError.exceededUnsuccessfulRequests
        case 429:
            throw SmartIdError.tooManyRequests
        case 480:
            throw SmartIdError.oldApi
        case 580:
            throw SmartIdError.underMaintenance
        default:
            throw SmartIdError.technicalError
        }
    }
}
