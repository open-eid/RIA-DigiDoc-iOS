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

        mockConfigurationService.fetchConfigurationHandler = { _ in expectedConfiguration }

        let result = try await repository.fetchConfiguration(proxyInfo: ProxyInfo())

        #expect(expectedConfiguration == result)
        #expect(mockConfigurationService.fetchConfigurationCallCount == 1)
    }

    @Test
    func fetchPublicKey_success() async throws {
        let expectedPublicKey = "MockPublicKey"

        mockConfigurationService.fetchPublicKeyHandler = { _ in expectedPublicKey }

        let result = try await repository.fetchPublicKey(proxyInfo: ProxyInfo())

        #expect(expectedPublicKey == result)
        #expect(mockConfigurationService.fetchPublicKeyCallCount == 1)
    }

    @Test
    func fetchSignature_success() async throws {
        let expectedSignature = "MockSignature"

        mockConfigurationService.fetchSignatureHandler = { _ in expectedSignature }

        let result = try await repository.fetchSignature(proxyInfo: ProxyInfo())

        #expect(expectedSignature == result)
        #expect(mockConfigurationService.fetchSignatureCallCount == 1)
    }

    @Test
    func fetchConfiguration_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 1, userInfo: nil)

        mockConfigurationService.fetchConfigurationHandler = { _ in throw expectedError }

        await #expect(throws: (any Error).self) { try await repository.fetchConfiguration(proxyInfo: ProxyInfo()) }
        #expect(mockConfigurationService.fetchConfigurationCallCount == 1)
    }

    @Test
    func fetchPublicKey_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 2, userInfo: nil)

        mockConfigurationService.fetchPublicKeyHandler = { _ in throw expectedError }

        await #expect(throws: (any Error).self) { try await repository.fetchPublicKey(proxyInfo: ProxyInfo()) }
        #expect(mockConfigurationService.fetchPublicKeyCallCount == 1)
    }

    @Test
    func fetchSignature_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 3, userInfo: nil)

        mockConfigurationService.fetchSignatureHandler = { _ in throw expectedError }

        await #expect(throws: (any Error).self) { try await repository.fetchSignature(proxyInfo: ProxyInfo()) }
        #expect(mockConfigurationService.fetchSignatureCallCount == 1)
    }
}
