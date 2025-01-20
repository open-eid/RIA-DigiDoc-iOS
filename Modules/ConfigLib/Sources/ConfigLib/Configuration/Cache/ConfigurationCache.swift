import Foundation
import CommonsLib
import UtilsLib

actor ConfigurationCache {

    static func cacheConfigurationFiles(
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

    static func getCachedFile(fileName: String, configDir: URL) throws -> URL {
        let configFile = configDir.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: configFile.path) else {
            throw ConfigurationCacheError.fileNotFound
        }
        return configFile
    }

    private static func cacheFile(fileName: String, data: Data, configDir: URL) async throws {
        let configFile = configDir.appendingPathComponent(fileName)

        do {
            try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
            try data.write(to: configFile)
        } catch {
            throw ConfigurationCacheError.unableToCacheFile(fileName)
        }
    }
}
