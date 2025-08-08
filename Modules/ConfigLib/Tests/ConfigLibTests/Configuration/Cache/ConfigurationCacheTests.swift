import Foundation
import Testing
import FactoryKit
import CommonsLib
import UtilsLib
import CommonsTestShared
import CommonsLibMocks

@testable import ConfigLib

struct ConfigurationCacheTests {

    private let mockFileManager: FileManagerProtocolMock

    private let configurationCache: ConfigurationCacheProtocol

    private let configDirectory: URL

    private let validConfData = TestConfigurationUtil.mockConfigurationResponse()
    private let validPublicKey = "valid public key"
    private let validSignature = "valid signature"

    init() async throws {
        self.mockFileManager = FileManagerProtocolMock()
        self.configurationCache = ConfigurationCache(fileManager: mockFileManager)
        self.configDirectory = try Directories.getConfigDirectory(fileManager: mockFileManager)
    }

    @Test
    func cacheConfigurationFiles_successWithValidData() async throws {
        let configurationCache = ConfigurationCache(fileManager: Container.shared.fileManager())
        let configDir = FileManager.default.temporaryDirectory.appendingPathComponent(
            "ConfigurationCacheTests-\(UUID().uuidString)"
        )
        let confFile = configDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let pubFile = configDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let sigFile = configDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try await configurationCache.cacheConfigurationFiles(
            confData: validConfData,
            publicKey: validPublicKey,
            signature: validSignature,
            configDir: configDir
        )

        let cachedConfiguration = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigJson,
            configDir: configDir
        )

        let cachedPublicKey = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigPub,
            configDir: configDir
        )

        let cachedSignature = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigRsa,
            configDir: configDir
        )

        #expect(cachedConfiguration == confFile)
        #expect(cachedPublicKey == pubFile)
        #expect(cachedSignature == sigFile)
    }

    @Test
    func cacheConfigurationFiles_throwsErrorWhenFileURLNotFound() async throws {
        let nonExistentDirectoryURL = URL(string: "notURL")

        guard let nonExistentDirectory = nonExistentDirectoryURL else {
            Issue.record("Invalid URL")
            return
        }

        await #expect(
            throws: ConfigurationCacheError.unableToCacheFile(CommonsLib.Constants.Configuration.CachedConfigJson)
        ) {
            try await configurationCache.cacheConfigurationFiles(
                confData: validConfData,
                publicKey: validPublicKey,
                signature: validSignature,
                configDir: nonExistentDirectory
            )
        }
    }

    @Test
    func getCachedFile_throwsErrorWhenFileNotFound() async throws {
        let nonExistentFile = "non_existent_file.json"

        await #expect(
            throws: ConfigurationCacheError.fileNotFound
        ) {
            try await configurationCache.getCachedFile(
                fileName: nonExistentFile,
                configDir: configDirectory
            )
        }
    }

    @Test
    func getCachedFile_throwsErrorWhenFileURLNotFound() async throws {
        let nonExistentDirectoryURL = URL(string: "notURL")

        guard let nonExistentDirectory = nonExistentDirectoryURL else {
            Issue.record("Invalid URL")
            return
        }

        mockFileManager.fileExistsHandler = { _ in false }

        await #expect(
            throws: ConfigurationCacheError.fileNotFound
        ) {
            try await configurationCache.getCachedFile(
                fileName: CommonsLib.Constants.Configuration.CachedConfigJson,
                configDir: nonExistentDirectory
            )
        }
    }
}
