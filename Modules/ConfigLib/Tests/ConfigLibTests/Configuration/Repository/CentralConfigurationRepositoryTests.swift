// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import ConfigLibMocks
import Foundation
import Testing

@testable import ConfigLib

struct CentralConfigurationRepositoryTests {
    private let mockConfigurationService: CentralConfigurationServiceProtocolMock!
    private let repository: CentralConfigurationRepository!

    init() async throws {
        mockConfigurationService = CentralConfigurationServiceProtocolMock()
        repository = CentralConfigurationRepository(centralConfigurationService: mockConfigurationService)
    }

    @Test
    func fetchConfiguration_success() async throws {
        let expectedConfiguration = "MockConfiguration"

        mockConfigurationService.fetchConfigurationHandler = { _, _ in expectedConfiguration }

        let result = try await repository.fetchConfiguration(proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")

        #expect(expectedConfiguration == result)
        #expect(mockConfigurationService.fetchConfigurationCallCount == 1)
    }

    @Test
    func fetchSignature_success() async throws {
        let expectedSignature = "MockSignature"

        mockConfigurationService.fetchSignatureHandler = { _, _ in expectedSignature }

        let result = try await repository.fetchSignature(proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")

        #expect(expectedSignature == result)
        #expect(mockConfigurationService.fetchSignatureCallCount == 1)
    }

    @Test
    func fetchConfiguration_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 1, userInfo: nil)

        mockConfigurationService.fetchConfigurationHandler = { _, _ in throw expectedError }

        await #expect(throws: (any Error).self) {
            try await repository.fetchConfiguration(proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")
        }
        #expect(mockConfigurationService.fetchConfigurationCallCount == 1)
    }

    @Test
    func fetchSignature_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 3, userInfo: nil)

        mockConfigurationService.fetchSignatureHandler = { _, _ in throw expectedError }

        await #expect(throws: (any Error).self) {
            try await repository.fetchSignature(proxyInfo: ProxyInfo(), userAgent: "TestUserAgent")
        }
        #expect(mockConfigurationService.fetchSignatureCallCount == 1)
    }
}
