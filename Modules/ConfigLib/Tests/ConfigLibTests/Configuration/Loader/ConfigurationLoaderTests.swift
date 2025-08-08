import Foundation
import Testing
import CommonsLib
import UtilsLib
import CommonsTestShared
import ConfigLibMocks
import CommonsLibMocks

@testable import ConfigLib

struct ConfigurationLoaderTests {

    let mockCentralConfigurationRepository: CentralConfigurationRepositoryProtocolMock!
    let mockConfigurationProperties: ConfigurationPropertiesProtocolMock!
    let mockConfigurationSignatureVerifier: ConfigurationSignatureVerifierProtocolMock!
    let mockConfigurationCache: ConfigurationCacheProtocolMock!
    let mockFileManager: FileManagerProtocolMock!
    let mockBundle: BundleProtocolMock!

    var configurationLoader: ConfigurationLoader!

    let configurationResponse = TestConfigurationUtil.mockConfigurationResponse()

    init() async throws {
        mockCentralConfigurationRepository = CentralConfigurationRepositoryProtocolMock()
        mockConfigurationProperties = ConfigurationPropertiesProtocolMock()
        mockConfigurationSignatureVerifier = ConfigurationSignatureVerifierProtocolMock()
        mockConfigurationCache = ConfigurationCacheProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockBundle = BundleProtocolMock()

        configurationLoader = ConfigurationLoader(
            centralConfigurationRepository: mockCentralConfigurationRepository,
            configurationProperty: mockConfigurationProperty(),
            configurationProperties: mockConfigurationProperties,
            configurationSignatureVerifier: mockConfigurationSignatureVerifier,
            configurationCache: mockConfigurationCache,
            fileManager: mockFileManager,
            bundle: mockBundle
        )
    }

    @Test
    func initConfiguration_success() async throws {

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Date(timeIntervalSince1970: Date.now.timeIntervalSince1970)
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }
        mockConfigurationProperties.setConfigurationLastCheckDateHandler = { _ in }
        mockConfigurationProperties.setConfigurationUpdatedDateHandler = { _ in }

        mockCentralConfigurationRepository.fetchConfigurationHandler = { configurationResponse }
        mockCentralConfigurationRepository.fetchPublicKeyHandler = { "some key" }
        mockCentralConfigurationRepository.fetchSignatureHandler = { "some signature" }

        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")
        mockFileManager.urlsHandler = { directory, domain in
            guard directory == .cachesDirectory, domain == .userDomainMask else {
                return []
            }
            return [mockCacheDir]
        }

        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        try await configurationLoader.initConfiguration(cacheDir: mockCacheDir)

        defer {
            try? FileManager.default.removeItem(at: cacheDir)
        }

        #expect(mockConfigurationCache.cacheConfigurationFilesCallCount == 1)
        #expect(mockConfigurationProperties.getConfigurationPropertiesCallCount == 1)
        #expect(mockConfigurationSignatureVerifier.verifyConfigurationSignatureCallCount == 1)
    }

    @Test
    func getConfUpdates_success() async throws {

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }
        mockConfigurationProperties.setConfigurationLastCheckDateHandler = { _ in }
        mockConfigurationProperties.setConfigurationUpdatedDateHandler = { _ in }

        mockCentralConfigurationRepository.fetchConfigurationHandler = { configurationResponse }
        mockCentralConfigurationRepository.fetchPublicKeyHandler = { "some key" }
        mockCentralConfigurationRepository.fetchSignatureHandler = { "some signature" }

        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        let updates = await configurationLoader.getConfigurationUpdates()

        try await configurationLoader.loadDefaultConfiguration(cacheDir: nil)

        defer {
            try? FileManager.default.removeItem(at: cacheDir)
        }

        for try await config in updates {
            #expect(config != nil)
            return
        }
    }

    @Test
    func loadDefaultConfiguration_success() async throws {

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }
        mockConfigurationProperties.setConfigurationLastCheckDateHandler = { _ in }
        mockConfigurationProperties.setConfigurationUpdatedDateHandler = { _ in }

        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        try await configurationLoader.loadDefaultConfiguration(cacheDir: nil)

        #expect(mockConfigurationSignatureVerifier.verifyConfigurationSignatureCallCount == 1)
    }

    @Test
    func loadDefaultConfiguration_throwsConfigurationNotFoundErrorWhenConfigurationNotFound() async throws {
        do {
            try await configurationLoader.loadDefaultConfiguration(cacheDir: nil)
            Issue.record(
                "Expected ConfigurationLoaderError.configurationNotFound to be thrown"
            )
            return
        } catch let error as ConfigurationLoaderError {
            #expect(ConfigurationLoaderError.configurationNotFound == error)
        } catch {
            Issue.record("Unexpected error thrown: \(error)")
            return
        }
    }

    @Test
    func loadDefaultConfiguration_throwsErrorWhenConfigurationVerificationFails() async throws {

        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in
            throw ConfigurationLoaderError.configurationVerificationFailed
        }

        do {
            try await configurationLoader.loadDefaultConfiguration(cacheDir: nil)
            Issue.record(
                "Expected ConfigurationLoaderError.configurationVerificationFailed to be thrown"
            )
            return
        } catch let error as ConfigurationLoaderError {
            #expect(ConfigurationLoaderError.configurationVerificationFailed == error)
        } catch {
            Issue.record("Unexpected error thrown: \(error)")
            return
        }
    }

    func initConfiguration_createsDirectoryWhenCacheDirectoryDoesNotExist() async throws {

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }
        mockConfigurationProperties.setConfigurationLastCheckDateHandler = { _ in }
        mockConfigurationProperties.setConfigurationUpdatedDateHandler = { _ in }

        mockCentralConfigurationRepository.fetchConfigurationHandler = { configurationResponse }
        mockCentralConfigurationRepository.fetchPublicKeyHandler = { "some key" }
        mockCentralConfigurationRepository.fetchSignatureHandler = { "some signature" }

        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")

        try await configurationLoader.initConfiguration(cacheDir: mockCacheDir)

        mockFileManager.urlsHandler = { directory, domain in
            guard directory == .cachesDirectory, domain == .userDomainMask else {
                return []
            }
            return [mockCacheDir]
        }

        #expect(mockConfigurationProperties.getConfigurationPropertiesCallCount == 2)
        #expect(mockConfigurationSignatureVerifier.verifyConfigurationSignatureCallCount == 3)
    }

    @Test
    func getConfiguration_returnNilWhenNoConfigurationSet() async {
        let configuration = await configurationLoader.getConfiguration()

        #expect(configuration == nil)
    }

    @Test
    func loadConfigurationProperty_successUpdatingConfigurationProperty() async throws {
        let testProperties = ConfigurationProperty(
            centralConfigurationServiceUrl: "https://test-url.com",
            updateInterval: 4,
            versionSerial: 1,
            downloadDate: Date()
        )

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in testProperties }

        let properties = try await configurationLoader.loadConfigurationProperty()
        let serviceUrl = await properties.centralConfigurationServiceUrl
        let updateInterval = await properties.updateInterval

        #expect("https://test-url.com" == serviceUrl)
        #expect(4 == updateInterval)

        #expect(mockConfigurationProperties.getConfigurationPropertiesCallCount == 1)
    }

    @Test
    func loadCachedConfiguration_loadsCachedConfigurationWhenAfterCentralCheckFalse() async throws {
        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }

        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        try await configurationLoader
            .loadCachedConfiguration(afterCentralCheck: false, cacheDir: mockCacheDir)

        await #expect(configurationLoader.getConfiguration() != nil)
        #expect(mockConfigurationSignatureVerifier.verifyConfigurationSignatureCallCount == 1)
        #expect(
            mockConfigurationSignatureVerifier.verifyConfigurationSignatureArgValues.first ?? ("", "", "") == (
                configurationResponse,
                "publicKey",
                "validSignature"
            )
        )
    }

    @Test
    func loadCachedConfiguration_loadsCachedConfigurationWhenAfterCentralCheckTrueAndUpdated() async throws {
        let mockCacheDir = URL(fileURLWithPath: "/mock/cache/dir")

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }

        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        try await configurationLoader
            .loadCachedConfiguration(afterCentralCheck: true, cacheDir: mockCacheDir)

        await #expect(configurationLoader.getConfiguration() != nil)
        #expect(
            mockConfigurationSignatureVerifier.verifyConfigurationSignatureArgValues.first ?? ("", "", "") == (
                configurationResponse,
                "publicKey",
                "validSignature"
            )
        )
    }

    @Test
    func loadCachedConfiguration_loadsDefaultConfigurationWhenNoCachedFiles() async throws {
        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }

        try await configurationLoader
            .loadCachedConfiguration(afterCentralCheck: false, cacheDir: nil)

        await #expect(configurationLoader.getConfiguration() != nil)
        #expect(
            mockConfigurationSignatureVerifier.verifyConfigurationSignatureArgValues.first ?? ("", "", "") == (
                configurationResponse,
                "publicKey",
                "validSignature"
            )
        )
    }

    @Test
    func loadCentralConfiguration_loadsCachedConfigurationWhenNoUpdatedConfiguration() async throws {
        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }
        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }
        mockConfigurationProperties.setConfigurationLastCheckDateHandler = { _ in }
        mockConfigurationProperties.setConfigurationUpdatedDateHandler = { _ in }

        mockCentralConfigurationRepository.fetchConfigurationHandler = { configurationResponse }
        mockCentralConfigurationRepository.fetchPublicKeyHandler = { "publicKey" }
        mockCentralConfigurationRepository.fetchSignatureHandler = { "validSignature" }

        mockConfigurationCache.getCachedFileHandler = { _, _ in signatureFile }

        try await configurationLoader.loadCentralConfiguration(cacheDir: nil)

        await #expect(configurationLoader.getConfiguration() != nil)
        #expect(
            mockConfigurationSignatureVerifier.verifyConfigurationSignatureArgValues.first ?? ("", "", "") == (
                configurationResponse,
                "publicKey",
                "validSignature"
            )
        )
    }

    @Test
    func loadCentralConfiguration_throwSignatureVerificationErrorWhenSignatureVerificationFails() async throws {
        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in
            throw ConfigurationLoaderError.configurationVerificationFailed
        }

        mockConfigurationProperties.getConfigurationPropertiesHandler = { _ in mockConfigurationProperty() }

        mockConfigurationCache.getCachedFileHandler = { _, _ in signatureFile }

        mockCentralConfigurationRepository.fetchConfigurationHandler = { configurationResponse }
        mockCentralConfigurationRepository.fetchPublicKeyHandler = { "some key" }
        mockCentralConfigurationRepository.fetchSignatureHandler = { "some signature" }

        await #expect(throws: ConfigurationLoaderError.configurationVerificationFailed) {
            try await configurationLoader.loadCentralConfiguration(cacheDir: nil)
        }
    }

    @Test
    func loadCachedConfiguration_loadsDefaultConfigurationWhenCachedConfigurationDoesNotExist() async throws {
        let cacheDirURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(
            "ConfigurationLoaderTests-\(UUID().uuidString)"
        )

        guard let cacheDir = cacheDirURL else {
            Issue.record("Unable to get cache directory")
            return
        }

        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let confFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = cacheDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        try configurationResponse.write(to: confFile, atomically: true, encoding: .utf8)
        try "publicKey".write(to: publicKeyFile, atomically: true, encoding: .utf8)
        try "validSignature".write(to: signatureFile, atomically: true, encoding: .utf8)

        let fileMap: [String: URL] = [
            CommonsLib.Constants.Configuration.DefaultConfigJson: confFile,
            CommonsLib.Constants.Configuration.DefaultConfigPub: publicKeyFile,
            CommonsLib.Constants.Configuration.DefaultConfigRsa: signatureFile
        ]

        mockBundle.urlHandler = { name, _ in
            if let name = name {
                return fileMap[name]
            }
            return nil
        }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        mockConfigurationProperties.updatePropertiesHandler = { _, _, _ in }
        mockConfigurationProperties.getConfigurationLastCheckDateHandler = {
            Calendar.current.date(byAdding: .day, value: -4, to: Date())
        }
        mockConfigurationProperties.getConfigurationUpdatedDateHandler = {
            Calendar.current.date(byAdding: .day, value: -10, to: Date())
        }

        let mockConfigDir = URL(fileURLWithPath: "/non/existent/folder")

        try await configurationLoader.loadCachedConfiguration(afterCentralCheck: false, cacheDir: mockConfigDir)

        await #expect(configurationLoader.getConfiguration() != nil)
        #expect(
            mockConfigurationSignatureVerifier.verifyConfigurationSignatureArgValues.first ?? ("", "", "") == (
                configurationResponse,
                "publicKey",
                "validSignature"
            )
        )
    }

    @Test
    func shouldCheckForUpdates_returnsTrueWhenLastUpdateWasMoreThanFourDays() async throws {
        let lastCheckDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())

        mockConfigurationProperties.getConfigurationLastCheckDateHandler = { lastCheckDate }

        let shouldUpdate = try await configurationLoader.shouldCheckForUpdates()

        #expect(shouldUpdate)
        #expect(mockConfigurationProperties.getConfigurationLastCheckDateCallCount == 1)
    }

    @Test
    func shouldCheckForUpdates_returnsFalseWhenLastUpdateWasLessThanFourDays() async throws {
        let lastCheckDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())

        mockConfigurationProperties.getConfigurationLastCheckDateHandler = { lastCheckDate }

        let shouldUpdate = try await configurationLoader.shouldCheckForUpdates()

        #expect(!shouldUpdate)
        #expect(mockConfigurationProperties.getConfigurationLastCheckDateCallCount == 1)
    }

    @Test
    func shouldCheckForUpdates_returnsTrueWhenLastUpdateNotExist() async throws {

        mockConfigurationProperties.getConfigurationLastCheckDateHandler = { nil }

        mockConfigurationSignatureVerifier.verifyConfigurationSignatureHandler = { _, _, _ in }

        let shouldUpdate = try await configurationLoader.shouldCheckForUpdates()

        #expect(shouldUpdate)
        #expect(mockConfigurationProperties.getConfigurationLastCheckDateCallCount == 1)
    }

    private func mockConfigurationProperty() -> ConfigurationProperty {
        return ConfigurationProperty(
            centralConfigurationServiceUrl: "https://www.someUrl.abc",
            updateInterval: 4,
            versionSerial: 100,
            downloadDate: Date()
        )
    }
}
