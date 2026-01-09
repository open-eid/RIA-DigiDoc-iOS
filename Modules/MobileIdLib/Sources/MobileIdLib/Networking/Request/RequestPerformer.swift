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
            let headers = RequestPerformer.defaultHeaders()

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

    private static func defaultHeaders() -> HTTPHeaders {
        [
            .contentType("application/json; charset=utf-8"),
            .init(name: "Cache-Control", value: "no-cache"),
            .init(name: "Pragma", value: "no-cache")
        ]
    }
}
