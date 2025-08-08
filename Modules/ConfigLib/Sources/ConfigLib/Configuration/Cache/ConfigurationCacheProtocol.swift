import Foundation
import CommonsLib

/// @mockable
public protocol ConfigurationCacheProtocol: Sendable {
    func cacheConfigurationFiles(
        confData: String,
        publicKey: String,
        signature: String,
        configDir: URL
    ) async throws

    func getCachedFile(
        fileName: String,
        configDir: URL
    ) async throws -> URL
}
