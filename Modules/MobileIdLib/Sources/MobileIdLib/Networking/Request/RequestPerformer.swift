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
        let encoder: ParameterEncoder = method == .get ?
        URLEncodedFormParameterEncoder.default :
        JSONParameterEncoder.default

        do {
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

            try responseHandler.handleSigningError(response)

            return try response.result.get()
        } catch {
            RequestPerformer.logger().error(
                "Unable to perform Mobile-ID request: \(error)"
            )

            try responseHandler.handleCancellationError(error)

            guard let mobileIdError = error as? MobileIdError else {
                throw MobileIdError.generalError
            }

            throw mobileIdError
        }
    }
}
