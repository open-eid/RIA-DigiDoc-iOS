// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
                .error("Unable to fetch central configuration: \(String(reflecting: error))")
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
                .error("Unable to fetch central configuration signature: \(String(reflecting: error))")
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
