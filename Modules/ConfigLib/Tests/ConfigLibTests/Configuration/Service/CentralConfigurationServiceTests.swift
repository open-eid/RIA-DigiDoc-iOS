import Foundation
import Testing
import Alamofire
import CommonsLib
import CommonsTestShared
import CommonsLibMocks

@testable import ConfigLib

struct CentralConfigurationServiceTests {
    private let mockUrlProtocol: URLProtocolProtocolMock
    private let configurationProperty: ConfigurationProperty

    init() throws {
        mockUrlProtocol = URLProtocolProtocolMock()

        configurationProperty = ConfigurationProperty(
            centralConfigurationServiceUrl: "https://someUrl.abc/config",
            updateInterval: 3600,
            versionSerial: 1,
            downloadDate: Date()
        )
    }

    @Test
    func fetchConfiguration_success() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/config/config.json")

        guard let url = mockUrl else {
            throw URLError(.badURL)
        }

        let mockData = Data("{\"configKey\": \"configValue\"}".utf8)
        let mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        let session = makeMockedSession { _ in
            return (response, mockData)
        }

        let service = CentralConfigurationService(
            userAgent: "TestUserAgent",
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/config",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        let result = try await service.fetchConfiguration()
        #expect(result == "{\"configKey\": \"configValue\"}")
    }

    @Test
    func fetchConfiguration_throwResponseValidationError() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/error/config.json")

        guard let url = mockUrl else {
            throw URLError(.badURL)
        }

        let mockData = Data("{\"configKey\": \"configValue\"}".utf8)
        let mockResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)

        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        let session = makeMockedSession { _ in
            return (response, mockData)
        }

        let errorService = CentralConfigurationService(
            userAgent: "TestUserAgent",
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/error/",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        await #expect(throws: Alamofire.AFError.self) {
            try await errorService.fetchConfiguration()
        }
    }

    @Test
    func fetchPublicKey_success() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/config/config.pub")

        guard let url = mockUrl else {
            throw URLError(.badURL)
        }

        let mockData = Data("public key".utf8)

        let mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        let session = makeMockedSession { _ in
            return (response, mockData)
        }

        let service = CentralConfigurationService(
            userAgent: "TestUserAgent",
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/config",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        let fetchedPublicKey = try await service.fetchPublicKey()
        #expect(fetchedPublicKey == String(data: mockData, encoding: .utf8))
    }

    @Test
    func fetchPublicKey_throwResponseValidationError() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/error/config.pub")

        guard let url = mockUrl else {
            throw URLError(.badURL)
        }

        let mockData = Data("public key".utf8)
        let mockResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)

        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        let session = makeMockedSession { _ in
            return (response, mockData)
        }

        let errorService = CentralConfigurationService(
            userAgent: "TestUserAgent",
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/error/",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        await #expect(throws: Alamofire.AFError.self) {
            try await errorService.fetchPublicKey()
        }
    }

    @Test
    func fetchSignature_success() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/config/config.rsa")

        guard let url = mockUrl else {
            throw URLError(.badURL)
        }

        let mockData = Data("signature".utf8)

        let mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        let session = makeMockedSession { _ in
            return (response, mockData)
        }

        let service = CentralConfigurationService(
            userAgent: "TestUserAgent",
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/config",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        let fetchedSignature = try await service.fetchSignature()
        #expect(fetchedSignature == String(data: mockData, encoding: .utf8))
    }

    @Test
    func fetchSignature_throwResponseValidationError() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/error/config.rsa")

        guard let url = mockUrl else {
            throw URLError(.badURL)
        }

        let mockData = Data("signature".utf8)
        let mockResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: nil)

        guard let response = mockResponse else {
            throw URLError(.badServerResponse)
        }

        let session = makeMockedSession { _ in
            return (response, mockData)
        }

        let errorService = CentralConfigurationService(
            userAgent: "TestUserAgent",
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/error/",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        await #expect(throws: Alamofire.AFError.self) {
            try await errorService.fetchSignature()
        }
    }
}
