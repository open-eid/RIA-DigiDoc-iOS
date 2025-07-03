import Foundation
import FactoryKit
import CommonsLib
import UtilsLib

actor ConfigurationCache {

    private let fileManager: FileManagerProtocol

    init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    static func cacheConfigurationFiles(
        confData: String,
        publicKey: String,
        signature: String,
        configDir: URL,
        fileManager: FileManagerProtocol = Container.shared.fileManager()
    ) async throws {
        guard let confDataBytes = confData.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for confData")
        }
        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigJson,
            data: confDataBytes,
            configDir: configDir,
            fileManager: fileManager
        )

        guard let publicKeyBytes = publicKey.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for publicKey")
        }
        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigPub,
            data: publicKeyBytes,
            configDir: configDir,
            fileManager: fileManager
        )

        guard let signatureBytes = signature.data(using: .utf8) else {
            throw ConfigurationCacheError.invalidData("Invalid UTF-8 encoding for signature")
        }
        try await cacheFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigRsa,
            data: signatureBytes,
            configDir: configDir,
            fileManager: fileManager
        )
    }

    static func getCachedFile(
        fileName: String,
        configDir: URL,
        fileManager: FileManagerProtocol
    ) throws -> URL {
        let configFile = configDir.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: configFile.path) else {
            throw ConfigurationCacheError.fileNotFound
        }
        return configFile
    }

    private static func cacheFile(
        fileName: String,
        data: Data,
        configDir: URL,
        fileManager: FileManagerProtocol
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
            throw ConfigurationCacheError.unableToCacheFile(fileName)
        }
    }
}
