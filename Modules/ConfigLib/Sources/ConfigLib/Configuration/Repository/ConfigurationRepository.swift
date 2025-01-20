import Foundation
import UtilsLib
import Alamofire

public actor ConfigurationRepository: ConfigurationRepositoryProtocol {

    private let configurationLoader: ConfigurationLoaderProtocol

    private var continuation: AsyncThrowingStream<ConfigurationProvider?, Error>?

    @MainActor
    public init(
        configurationLoader: ConfigurationLoaderProtocol = ConfigLibAssembler.shared.resolve(
            ConfigurationLoaderProtocol.self
        )
    ) {
        self.configurationLoader = configurationLoader
    }

    public func getConfiguration() async -> ConfigurationProvider? {
        return await configurationLoader.getConfiguration()
    }

    public func getConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>? {
        return await configurationLoader.getConfigurationUpdates()
    }

    public func getCentralConfiguration(cacheDir: URL?) async throws -> ConfigurationProvider? {
        let configDir = try cacheDir ?? Directories.getConfigDirectory()

        try await configurationLoader.loadCentralConfiguration(cacheDir: configDir)
        return await getConfiguration()
    }

    public func getCentralConfigurationUpdates(
        cacheDir: URL?
    ) async throws -> AsyncThrowingStream<
        ConfigurationProvider?,
        Error
    >? {
        let configDir = try cacheDir ?? Directories.getConfigDirectory()

        try await configurationLoader.loadCentralConfiguration(cacheDir: configDir)
        return await getConfigurationUpdates()
    }

    public func observeConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>? {

        let loaderStream = await configurationLoader.getConfigurationUpdates()

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await config in loaderStream {
                        if let config = config {
                            continuation.yield(config)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
