import Foundation
import Alamofire
import CommonsLib

public actor CentralConfigurationService: CentralConfigurationServiceProtocol {

    private let userAgent: String
    private let configurationProperty: ConfigurationProperty
    private let session: Session?

    @MainActor
    public init(
        userAgent: String,
        configurationProperty: ConfigurationProperty = ConfigLibAssembler.shared.resolve(ConfigurationProperty.self),
        session: Session? = nil
    ) {
        self.userAgent = userAgent
        self.configurationProperty = configurationProperty
        self.session = session
    }

    public func fetchConfiguration() async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.json"
        let response: String = try await session.request(url)
            .validate()
            .serializingString()
            .value

        return response
    }

    public func fetchPublicKey() async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout
        )

        let url = "\(await configurationProperty.centralConfigurationServiceUrl)/config.pub"
        let response: String = try await session.request(url)
            .validate()
            .serializingString()
            .value

        return response
    }

    public func fetchSignature() async throws -> String {
        let session = self.session ?? constructHttpClient(
            defaultTimeout: CommonsLib.Constants.Configuration.DefaultTimeout
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
        customConfiguration: URLSessionConfiguration? = nil
    ) -> Session {
        let interceptor = constructAlamofireRequestInterceptor()

        let configuration = customConfiguration ?? {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = defaultTimeout
            config.timeoutIntervalForResource = defaultTimeout
            return config
        }()

        return Session(configuration: configuration, interceptor: interceptor)
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
