// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire
import CommonsLib
import UtilsLib

struct RequestPerformer: RequestPerfomerProtocol, Loggable {
    private let sessionProvider: SessionProviderProtocol
    private let responseHandler: ResponseHandlerProtocol

    init(
        sessionProvider: SessionProviderProtocol,
        responseHandler: ResponseHandlerProtocol
    ) {
        self.sessionProvider = sessionProvider
        self.responseHandler = responseHandler
    }

    func performRequest<T: Decodable & Sendable, P: Encodable & Sendable>(
        url: String,
        method: HTTPMethod,
        parameters: P? = nil,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let encoder: ParameterEncoder = method == .get ?
                    URLEncodedFormParameterEncoder.default :
                    JSONParameterEncoder.default

                    let session = try await sessionProvider.ensureSession(
                        url: url,
                        trustedCertificates: trustedCertificates,
                        proxyInfo: proxyInfo,
                        userAgent: userAgent
                    )

                    let response = await session.request(
                        url,
                        method: method,
                        parameters: parameters,
                        encoder: encoder
                    )
                        .validate()
                        .serializingDecodable(T.self)
                        .response

                    switch response.result {
                    case .success(let value):
                        if let response = value as? SmartIdSessionResponse, let result = response.result?.endResult {
                            do {
                                try responseHandler.handleSessionResult(result)
                            } catch {
                                continuation.resume(throwing: error)
                                return
                            }
                        }
                        continuation.resume(returning: value)
                        return
                    case .failure(let afError):
                        continuation.resume(with: Result {
                            try responseHandler.handleCancellationError(afError)
                            try responseHandler.handleNetworkError(afError, statusCode: response.response?.statusCode)

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
                        try responseHandler.handleCancellationError(error)
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
}
