// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire
import CommonsLib

extension Session {
    public static func withProxy(
        proxyInfo: ProxyInfo,
        timeout _: TimeInterval = 60,
        configuration: URLSessionConfiguration? = nil,
        interceptor: RequestInterceptor? = nil,
        serverTrustManager: ServerTrustManager? = nil
    ) -> Session {
        let configuration = configuration ?? URLSessionConfiguration.af.default

        if proxyInfo.option != .disabled, !proxyInfo.host.isEmpty {
            configuration.requestCachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData

            let proxyConfiguration: [AnyHashable: Any] = [
                kCFNetworkProxiesHTTPEnable as AnyHashable: true,
                kCFNetworkProxiesHTTPProxy as AnyHashable: proxyInfo.host,
                kCFNetworkProxiesHTTPPort as AnyHashable: proxyInfo.port,

                "HTTPSEnable": true,
                "HTTPSProxy": proxyInfo.host,
                "HTTPSPort": proxyInfo.port,

                kCFProxyUsernameKey as AnyHashable: proxyInfo.username,
                kCFProxyPasswordKey as AnyHashable: proxyInfo.password
            ]

            configuration.httpAdditionalHeaders = [
                "Proxy-Authorization": HTTPHeader.authorization(
                    username: proxyInfo.username,
                    password: proxyInfo.password)
                .value
            ]

            configuration.connectionProxyDictionary = proxyConfiguration
        }

        return Session(configuration: configuration, interceptor: interceptor, serverTrustManager: serverTrustManager)
    }
}
