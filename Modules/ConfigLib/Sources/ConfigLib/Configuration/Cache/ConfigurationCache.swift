import Foundation
import OSLog
import FactoryKit
import CommonsLib
import UtilsLib

actor ConfigurationCache: ConfigurationCacheProtocol {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.ConfigLib", category: "ConfigurationCache")

    private let fileManager: FileManagerProtocol

    init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    public func cacheConfigurationFiles(
        confData: String,
        publicKey: String,
        signature: String,
        configDir: URL
    ) async throws {
        guard let confDataBytes = confData.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for confData")
        }

        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigJson,
            data: confDataBytes,
            configDir: configDir
        )

        guard let publicKeyBytes = publicKey.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for publicKey")
        }

        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigPub,
            data: publicKeyBytes,
            configDir: configDir
        )

        guard let signatureBytes = signature.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for signature")
        }

        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigRsa,
            data: signatureBytes,
            configDir: configDir
        )
    }

    public func getCachedFile(
        fileName: String,
        configDir: URL
    ) async throws -> URL {
        let configFile = configDir.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: configFile.path) else {
            throw ConfigurationCacheError.fileNotFound
        }
        return configFile
    }

    private func cacheFile(
        fileName: String,
        data: Data,
        configDir: URL
    ) async throws {
        let configFile = configDir.appendingPathComponent(fileName)

        do {
            try fileManager.createDirectory(
                at: configDir,
                withIntermediateDirectories: true,
                attributes: nil
            )

            try data.write(to: configFile)
        } catch {
            ConfigurationCache.logger.error("\(error.localizedDescription)")
            throw ConfigurationCacheError.unableToCacheFile(fileName)
        }
    }
}
