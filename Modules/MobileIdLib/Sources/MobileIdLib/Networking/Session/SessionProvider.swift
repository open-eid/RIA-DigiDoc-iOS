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

actor SessionProvider: SessionProviderProtocol, Loggable {
    private var session: Session?
    private var currentProxy: ProxyInfo?

    func ensureSession(
        url: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> Session {
        if currentProxy == proxyInfo {
            if let existing = session { return existing }
        }

        currentProxy = proxyInfo

        guard let host = URL(string: url)?.host else {
            SessionProvider.logger().error(
                "Unable to parse host from URL: \(url)"
            )
            throw URLError(.badURL)
        }

        let newSession = SessionProvider.createAlamofireSession(
            host: host,
            trustedCertificates: trustedCertificates,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )
        session = newSession
        return newSession
    }

    private static func createAlamofireSession(
        host: String,
        trustedCertificates: [SecCertificate],
        proxyInfo: ProxyInfo,
        userAgent: String
    ) -> Session {
        let evaluators = [host: PinnedCertificatesTrustEvaluator(certificates: trustedCertificates)]
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(Constants.Signing.Timeout)
        config.timeoutIntervalForResource = TimeInterval(Constants.Signing.Timeout)
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil

        var headers = config.httpAdditionalHeaders ?? [:]
        headers["User-Agent"] = userAgent
        headers["Content-Type"] = "application/json; charset=utf-8"
        headers["Cache-Control"] = "no-cache"
        headers["Pragma"] = "no-cache"
        config.httpAdditionalHeaders = headers

        return Session.withProxy(
            proxyInfo: proxyInfo,
            configuration: config,
            serverTrustManager: ServerTrustManager(evaluators: evaluators)
        )
    }
}
