import Foundation
import Alamofire
import UtilsLib
import CommonsLib

public actor ConfigurationRepository: ConfigurationRepositoryProtocol {

    private let configurationLoader: ConfigurationLoaderProtocol
    private let fileManager: FileManagerProtocol

    private var continuation: AsyncThrowingStream<ConfigurationProvider?, Error>?

    public init(
        configurationLoader: ConfigurationLoaderProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.configurationLoader = configurationLoader
        self.fileManager = fileManager
    }

    public func getConfiguration() async -> ConfigurationProvider? {
        return await configurationLoader.getConfiguration()
    }

    public func getConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>? {
        return await configurationLoader.getConfigurationUpdates(replayLatest: true)
    }

    public func getCentralConfiguration(cacheDir: URL?) async throws -> ConfigurationProvider? {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        try await configurationLoader.loadCentralConfiguration(cacheDir: configDir)
        return await getConfiguration()
    }

    public func getCentralConfigurationUpdates(
        cacheDir: URL?
    ) async throws -> AsyncThrowingStream<
        ConfigurationProvider?,
        Error
    >? {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        try await configurationLoader.loadCentralConfiguration(cacheDir: configDir)
        return await getConfigurationUpdates()
    }

    public func observeConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>? {

        let loaderStream = await configurationLoader.getConfigurationUpdates(replayLatest: true)

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
