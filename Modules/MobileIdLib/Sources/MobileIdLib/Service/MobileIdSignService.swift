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

actor MobileIdSignService: MobileIdSignServiceProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "MobileIdSignService")

    private var session: Session?

    // swiftlint:disable:next function_parameter_count
    public func getCertificateRequest(
        url: String,
        relyingPartyName: String,
        relyingPartyUUID: String,
        phoneNumber: String,
        nationalIdentityNumber: String,
        trustedCertificates: [SecCertificate]
    ) async throws -> MobileIdCertificateResponse {
        let request = MobileIdCertificateRequest(
            relyingPartyName: relyingPartyName,
            relyingPartyUUID: relyingPartyUUID,
            phoneNumber: "+\(phoneNumber)",
            nationalIdentityNumber: nationalIdentityNumber
        )

        return try await performRequest(
            url: url,
            method: .post,
            parameters: request,
            trustedCertificates: trustedCertificates
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
        trustedCertificates: [SecCertificate]
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

        return try await performRequest(
            url: url,
            method: .post,
            parameters: request,
            trustedCertificates: trustedCertificates
        )
    }

    public func getSessionRequest(
        url: String,
        sessionId: String,
        pollingTimeout: Int,
        trustedCertificates: [SecCertificate]
    ) async throws -> MobileIdSessionResponse {
        let pollingTimeoutMs = pollingTimeout * 1000

        while true {
            let sessionResponse: MobileIdSessionResponse? = try await performRequest(
                url: "\(url)/\(sessionId)",
                method: .get,
                parameters: ["timeoutMs": pollingTimeoutMs],
                trustedCertificates: trustedCertificates
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

    private func performRequest<T: Decodable & Sendable, P: Encodable & Sendable>(
        url: String,
        method: HTTPMethod,
        parameters: P? = nil,
        trustedCertificates: [SecCertificate]
    ) async throws -> T {
        let encoder: ParameterEncoder = method == .get ?
        URLEncodedFormParameterEncoder.default :
        JSONParameterEncoder.default

        do {
            let session = try await ensureSession(url: url, trustedCertificates: trustedCertificates)
            let headers = MobileIdSignService.defaultHeaders()

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

            try handleSigningError(response)

            return try response.result.get()
        } catch {
            MobileIdSignService.logger.error(
                "Unable to perform Mobile-ID request: \(error)"
            )

            try handleCancellationError(error)

            guard let mobileIdError = error as? MobileIdError else {
                throw MobileIdError.generalError
            }

            throw mobileIdError
        }
    }

    private func ensureSession(url: String, trustedCertificates: [SecCertificate]) async throws -> Session {
        if let existing = session { return existing }

        guard let host = URL(string: url)?.host else {
            MobileIdSignService.logger.error(
                "Unable to parse host from URL: \(url)"
            )
            throw URLError(.badURL)
        }

        let newSession = MobileIdSignService.createAlamofireSession(
            host: host,
            trustedCertificates: trustedCertificates
        )
        session = newSession
        return newSession
    }

    private static func defaultHeaders() -> HTTPHeaders {
        [
            .contentType("application/json; charset=utf-8"),
            .init(name: "Cache-Control", value: "no-cache"),
            .init(name: "Pragma", value: "no-cache")
        ]
    }

    private static func createAlamofireSession(host: String, trustedCertificates: [SecCertificate]) -> Session {
        let evaluators = [host: PinnedCertificatesTrustEvaluator(certificates: trustedCertificates)]
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(Constants.Signing.Timeout)
        config.timeoutIntervalForResource = TimeInterval(Constants.Signing.Timeout)
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil

        return Session(
            configuration: config,
            serverTrustManager: ServerTrustManager(evaluators: evaluators)
        )
    }

    private func handleSigningError<T: Decodable>(_ response: DataResponse<T, AFError>) throws {
        if let error = response.error {
            try handleCancellationError(error)
            try handleNetworkError(error, statusCode: response.response?.statusCode)
            return
        }

        let responseValue = try response.result.get()

        try handleCertificateResponse(responseValue)
        try handleSessionResponse(responseValue)
    }

    private func handleCertificateResponse(_ responseValue: Any) throws {
        if let certificateResponse = responseValue as? MobileIdCertificateResponse {
            if [.notFound, .notActive].contains(certificateResponse.result) {
                throw MobileIdError.notMidClient
            }
        }
    }

    private func handleSessionResponse(_ responseValue: Any) throws {
        if let sessionResponse = responseValue as? MobileIdSessionResponse {
            guard sessionResponse.state == .complete else { return }

            try handleSessionResult(sessionResponse)
        }
    }

    private func handleSessionResult(_ response: MobileIdSessionResponse) throws {
        switch response.result {
        case .timeout:
            throw MobileIdError.timeout
        case .notMidClient:
            throw MobileIdError.notMidClient
        case .userCancelled:
            throw MobileIdError.userCancelled
        case .signatureHashMismatch:
            throw MobileIdError.signatureHashMismatch
        case .phoneAbsent:
            throw MobileIdError.phoneAbsent
        case .deliveryError:
            throw MobileIdError.deliveryError
        case .simError:
            throw MobileIdError.simError
        default:
            break
        }
    }

    private func handleCancellationError(_ error: Error) throws {
        if let afError = error as? AFError {
            switch afError {
            case .explicitlyCancelled:
                throw MobileIdError.explicitlyCancelled
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
            throw MobileIdError.noInternetConnection
        case .timedOut:
            throw MobileIdError.timeout
        default:
            throw MobileIdError.noInternetConnection
        }
    }

    private func handleStatusCodeError(_ statusCode: Int?) throws {
        switch statusCode ?? -1 {
        case 400:
            throw MobileIdError.incorrectParameters
        case 401:
            throw MobileIdError.invalidAccessRights
        case 409:
            throw MobileIdError.exceededUnsuccessfulRequests
        case 429:
            throw MobileIdError.tooManyRequests
        default:
            throw MobileIdError.technicalError
        }
    }
}
