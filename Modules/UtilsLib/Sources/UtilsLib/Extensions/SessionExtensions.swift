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
