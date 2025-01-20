import Foundation

public struct CentralConfigurationRepository: CentralConfigurationRepositoryProtocol {

    private let centralConfigurationService: CentralConfigurationServiceProtocol

    public init(centralConfigurationService: CentralConfigurationServiceProtocol) {
        self.centralConfigurationService = centralConfigurationService
    }

    public func fetchConfiguration() async throws -> String {
        return try await centralConfigurationService.fetchConfiguration()
    }

    public func fetchPublicKey() async throws -> String {
        return try await centralConfigurationService.fetchPublicKey()
    }

    public func fetchSignature() async throws -> String {
        return try await centralConfigurationService.fetchSignature()
    }
}
