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

public actor CentralConfigurationService: CentralConfigurationServiceProtocol {

    private let userAgent: String
    private let configurationProperty: ConfigurationProperty
    private let session: Session?

    public init(
        userAgent: String,
        configurationProperty: ConfigurationProperty,
        session: Session? = nil
    ) {
        self.userAgent = userAgent
        self.configurationProperty = configurationProperty
        self.session = session
    }

    public func fetchConfiguration(
        proxyInfo: ProxyInfo,
    ) async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout,
            proxyInfo: proxyInfo
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.json"
        let response: String = try await session.request(url)
            .validate()
            .serializingString()
            .value

        return response
    }

    public func fetchPublicKey(
        proxyInfo: ProxyInfo
    ) async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout,
            proxyInfo: proxyInfo
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.pub"
        let response: String = try await session.request(url)
            .validate()
            .serializingString()
            .value

        return response
    }

    public func fetchSignature(
        proxyInfo: ProxyInfo
    ) async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout,
            proxyInfo: proxyInfo
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.rsa"
        let responseData: Data = try await session.request(url)
            .validate()
            .serializingData()
            .value

        guard let responseString = String(data: responseData, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }

        return responseString
    }

    private func constructHttpClient(
        defaultTimeout: TimeInterval,
        proxyInfo: ProxyInfo,
        customConfiguration: URLSessionConfiguration? = nil,
    ) -> Session {
        let interceptor = constructAlamofireRequestInterceptor()

        let configuration = customConfiguration ?? {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = defaultTimeout
            config.timeoutIntervalForResource = defaultTimeout
            return config
        }()

        return Session.withProxy(
            proxyInfo: proxyInfo,
            configuration: configuration,
            interceptor: interceptor
        )
    }

    private func constructAlamofireRequestInterceptor() -> RequestInterceptor {
        return CustomRequestInterceptor(userAgent: userAgent)
    }
}

struct CustomRequestInterceptor: RequestInterceptor {

    private let userAgent: String

    init(userAgent: String) {
        self.userAgent = userAgent
    }

    // swiftlint:disable:next unused_parameter
    func adapt(_ request: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var modifiedRequest = request
        modifiedRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        completion(.success(modifiedRequest))
    }

    // swiftlint:disable:next blanket_disable_command
    // swiftlint:disable unused_parameter
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (
            RetryResult
        ) -> Void
    ) {
        completion(
            .doNotRetry
        )
    }
}
