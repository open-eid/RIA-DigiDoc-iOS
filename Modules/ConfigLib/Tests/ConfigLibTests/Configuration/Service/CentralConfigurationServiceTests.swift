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
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/config",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        let result = try await service.fetchConfiguration(
            proxyInfo: ProxyInfo(),
            userAgent: "CentralConfigurationServiceTests"
        )

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
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/error/",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        await #expect(throws: Error.self) {
            try await errorService.fetchConfiguration(proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")
        }
    }

    @Test
    func fetchSignature_success() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/config/config.ecc")

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
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/config",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        let fetchedSignature = try await service.fetchSignature(proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")
        #expect(fetchedSignature == String(data: mockData, encoding: .utf8))
    }

    @Test
    func fetchSignature_throwResponseValidationError() async throws {
        let mockUrl = URL(string: "https://someUrl.abc/error/config.ecc")

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
            configurationProperty: ConfigurationProperty(
                centralConfigurationServiceUrl: "https://someUrl.abc/error/",
                updateInterval: 3600,
                versionSerial: 1,
                downloadDate: Date()
            ),
            session: session
        )

        await #expect(throws: Error.self) {
            try await errorService.fetchSignature(proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")
        }
    }
}
