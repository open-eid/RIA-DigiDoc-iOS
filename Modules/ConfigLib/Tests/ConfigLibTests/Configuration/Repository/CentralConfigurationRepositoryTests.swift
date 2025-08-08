import Foundation
import Testing
import ConfigLibMocks

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

        mockConfigurationService.fetchConfigurationHandler = { expectedConfiguration }

        let result = try await repository.fetchConfiguration()

        #expect(expectedConfiguration == result)
        #expect(mockConfigurationService.fetchConfigurationCallCount == 1)
    }

    @Test
    func fetchPublicKey_success() async throws {
        let expectedPublicKey = "MockPublicKey"

        mockConfigurationService.fetchPublicKeyHandler = { expectedPublicKey }

        let result = try await repository.fetchPublicKey()

        #expect(expectedPublicKey == result)
        #expect(mockConfigurationService.fetchPublicKeyCallCount == 1)
    }

    @Test
    func fetchSignature_success() async throws {
        let expectedSignature = "MockSignature"

        mockConfigurationService.fetchSignatureHandler = { expectedSignature }

        let result = try await repository.fetchSignature()

        #expect(expectedSignature == result)
        #expect(mockConfigurationService.fetchSignatureCallCount == 1)
    }

    @Test
    func fetchConfiguration_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 1, userInfo: nil)

        mockConfigurationService.fetchConfigurationHandler = { throw expectedError }

        await #expect(throws: (any Error).self) { try await repository.fetchConfiguration() }
        #expect(mockConfigurationService.fetchConfigurationCallCount == 1)
    }

    @Test
    func fetchPublicKey_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 2, userInfo: nil)

        mockConfigurationService.fetchPublicKeyHandler = { throw expectedError }

        await #expect(throws: (any Error).self) { try await repository.fetchPublicKey() }
        #expect(mockConfigurationService.fetchPublicKeyCallCount == 1)
    }

    @Test
    func fetchSignature_throwsErrorWhenFetchingFails() async throws {
        let expectedError = NSError(domain: "Test", code: 3, userInfo: nil)

        mockConfigurationService.fetchSignatureHandler = { throw expectedError }

        await #expect(throws: (any Error).self) { try await repository.fetchSignature() }
        #expect(mockConfigurationService.fetchSignatureCallCount == 1)
    }
}
