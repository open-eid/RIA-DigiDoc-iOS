// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire
import CommonsLib
import UtilsLib

public actor SessionProvider: SessionProviderProtocol, Loggable {
    private var session: Session?
    private var currentProxy: ProxyInfo?

    public func ensureSession(
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
            SmartIdSignService.logger().error(
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
