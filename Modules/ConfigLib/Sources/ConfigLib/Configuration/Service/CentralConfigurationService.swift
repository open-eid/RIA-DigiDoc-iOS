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

public actor CentralConfigurationService: CentralConfigurationServiceProtocol, Loggable {
    private let configurationProperty: ConfigurationProperty
    private let session: Session?

    public init(
        configurationProperty: ConfigurationProperty,
        session: Session? = nil
    ) {
        self.configurationProperty = configurationProperty
        self.session = session
    }

    public func fetchConfiguration(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.json"

        do {
            let response: String = try await session.request(url)
                .validate()
                .serializingString()
                .value

            return response
        } catch {
            CentralConfigurationService.logger()
                .error("Unable to fetch central configuration: \(error)")
            throw URLError(.resourceUnavailable)
        }
    }

    public func fetchPublicKey(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.ecpub"

        do {
            let response: String = try await session.request(url)
                .validate()
                .serializingString()
                .value

            return response
        } catch {
            CentralConfigurationService.logger()
                .error("Unable to fetch central configuration public key: \(error)")
            throw URLError(.resourceUnavailable)
        }
    }

    public func fetchSignature(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout,
            proxyInfo: proxyInfo,
            userAgent: userAgent
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.ecc"
        do {
            let responseData: Data = try await session.request(url)
                .validate()
                .serializingData()
                .value

            guard let responseString = String(data: responseData, encoding: .utf8) else {
                throw URLError(.cannotDecodeContentData)
            }

            return responseString
        } catch {
            CentralConfigurationService.logger()
                .error("Unable to fetch central configuration signature: \(error)")
            throw URLError(.resourceUnavailable)
        }
    }

    private func constructHttpClient(
        defaultTimeout: TimeInterval,
        proxyInfo: ProxyInfo,
        customConfiguration: URLSessionConfiguration? = nil,
        userAgent: String
    ) -> Session {
        let retryInterceptor = constructAlamofireRetryRequestInterceptor()

        let configuration = customConfiguration ?? {
            let config = URLSessionConfiguration.af.default
            config.timeoutIntervalForRequest = defaultTimeout
            config.timeoutIntervalForResource = defaultTimeout

            var headers = config.httpAdditionalHeaders ?? [:]
            headers["User-Agent"] = userAgent
            headers["Content-Type"] = "application/json; charset=utf-8"
            headers["Cache-Control"] = "no-cache"
            headers["Pragma"] = "no-cache"
            config.httpAdditionalHeaders = headers
            return config
        }()

        return Session.withProxy(
            proxyInfo: proxyInfo,
            configuration: configuration,
            interceptor: retryInterceptor
        )
    }

    private func constructAlamofireRetryRequestInterceptor() -> RequestInterceptor {
        return RetryRequestInterceptor()
    }
}

struct RetryRequestInterceptor: RequestInterceptor {

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
