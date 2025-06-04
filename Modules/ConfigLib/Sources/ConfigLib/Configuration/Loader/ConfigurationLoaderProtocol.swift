import Foundation

/// @mockable
public protocol ConfigurationLoaderProtocol: Sendable {
    func initConfiguration(cacheDir: URL) async throws

    func loadConfigurationProperty() async throws -> ConfigurationProperty

    func loadCachedConfiguration(afterCentralCheck: Bool, cacheDir: URL?) async throws

    func loadDefaultConfiguration(bundle: Bundle, cacheDir: URL?) async throws

    func loadCentralConfiguration(cacheDir: URL?) async throws

    func shouldCheckForUpdates() async throws -> Bool

    func getConfiguration() async -> ConfigurationProvider?

    func getConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>
}
