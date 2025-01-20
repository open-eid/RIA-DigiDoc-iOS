import Foundation

public protocol ConfigurationRepositoryProtocol: Sendable {
    func getConfiguration() async -> ConfigurationProvider?

    func getCentralConfiguration(cacheDir: URL?) async throws -> ConfigurationProvider?

    func observeConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>?

    func getConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>?

    func getCentralConfigurationUpdates(
        cacheDir: URL?
    ) async throws -> AsyncThrowingStream<
        ConfigurationProvider?,
        Error
    >?
}
