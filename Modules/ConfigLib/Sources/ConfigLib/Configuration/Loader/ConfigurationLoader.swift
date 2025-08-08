import Foundation
import OSLog
import FactoryKit
import CommonsLib
import UtilsLib

public actor ConfigurationLoader: ConfigurationLoaderProtocol {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "ConfigurationLoader")

    private var configuration: ConfigurationProvider?

    private var continuation: AsyncThrowingStream<ConfigurationProvider?, Error>.Continuation?

    private let centralConfigurationRepository: CentralConfigurationRepositoryProtocol
    private var configurationProperty: ConfigurationProperty
    private let configurationProperties: ConfigurationPropertiesProtocol
    private let configurationSignatureVerifier: ConfigurationSignatureVerifierProtocol
    private let configurationCache: ConfigurationCacheProtocol

    private var fileManager: FileManagerProtocol
    private var bundle: BundleProtocol

    public init(
        centralConfigurationRepository: CentralConfigurationRepositoryProtocol,
        configurationProperty: ConfigurationProperty,
        configurationProperties: ConfigurationPropertiesProtocol,
        configurationSignatureVerifier: ConfigurationSignatureVerifierProtocol,
        configurationCache: ConfigurationCacheProtocol,
        fileManager: FileManagerProtocol,
        bundle: BundleProtocol?
    ) {
        self.centralConfigurationRepository = centralConfigurationRepository
        self.configurationProperty = configurationProperty
        self.configurationProperties = configurationProperties
        self.configurationSignatureVerifier = configurationSignatureVerifier
        self.configurationCache = configurationCache

        self.fileManager = fileManager
        self.bundle = bundle ?? Bundle.module
    }

    public func initConfiguration(cacheDir: URL) async throws {
        ConfigurationLoader.logger.debug("Initializing configuration")

        if !fileManager.fileExists(atPath: cacheDir.path) {
            try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        }

        try await loadCachedConfiguration(afterCentralCheck: false, cacheDir: cacheDir)

        try await loadConfigurationProperty()

        if try await shouldCheckForUpdates() {
            ConfigurationLoader.logger.debug("Checking for configuration updates...")
            try await loadCentralConfiguration(cacheDir: cacheDir)
        }

        ConfigurationLoader.logger.debug("Finished initializing configuration")

        finishConfigurationUpdate()
    }

    public func getConfiguration() -> ConfigurationProvider? {
        return configuration
    }

    @discardableResult
    public func loadConfigurationProperty() async throws -> ConfigurationProperty {
        let properties = try await configurationProperties
            .getConfigurationProperties(
                from: URL(fileURLWithPath: bundle.path(
                    forResource: Constants.Configuration.DefaultConfigurationPropertiesFileName,
                    ofType: "properties"
                ) ?? "")
            )

        await configurationProperty.update(
            centralConfigurationServiceUrl: properties.centralConfigurationServiceUrl,
            updateInterval: properties.updateInterval,
            versionSerial: properties.versionSerial,
            downloadDate: properties.downloadDate
        )

        return properties
    }

    public func loadCachedConfiguration(afterCentralCheck: Bool, cacheDir: URL?) async throws {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        let confFile = configDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigJson)
        let publicKeyFile = configDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigPub)
        let signatureFile = configDir.appendingPathComponent(CommonsLib.Constants.Configuration.CachedConfigRsa)

        let configFilesExist =
            fileManager.fileExists(atPath: confFile.path) &&
            fileManager.fileExists(atPath: publicKeyFile.path) &&
            fileManager.fileExists(atPath: signatureFile.path)

        if configFilesExist {
            ConfigurationLoader.logger.debug("Initializing cached configuration")

            let confFileContents = try String(contentsOf: confFile, encoding: .utf8)
            let publicKeyContents = try String(contentsOf: publicKeyFile, encoding: .utf8)
            let signatureContents = try String(contentsOf: signatureFile, encoding: .utf8)

            try configurationSignatureVerifier.verifyConfigurationSignature(
                config: confFileContents,
                publicKey: publicKeyContents,
                signature: signatureContents
            )

            var configurationProvider = try JSONDecoder().decode(
                ConfigurationProvider.self,
                from: Data(contentsOf: confFile)
            )

            ConfigurationLoader.logger.debug(
                "Using cached configuration version \(configurationProvider.metaInf.serial)"
            )

            try await configurationCache.cacheConfigurationFiles(
                confData: confFileContents,
                publicKey: publicKeyContents,
                signature: signatureContents,
                configDir: configDir
            )

            if !afterCentralCheck {
                await configurationProperties.updateProperties(
                    lastUpdateCheck: configurationProvider.configurationLastUpdateCheckDate,
                    lastUpdated: configurationProvider.configurationUpdateDate,
                    serial: configurationProvider.metaInf.serial
                )

                configurationProvider.configurationLastUpdateCheckDate = await configurationProperties
                    .getConfigurationLastCheckDate()
                configurationProvider.configurationUpdateDate = await configurationProperties
                    .getConfigurationUpdatedDate()

                configuration = configurationProvider
                updateConfiguration()
            } else {
                let currentDate = Date()
                configurationProvider.configurationUpdateDate = configurationProvider.configurationUpdateDate ??
                    configuration?.configurationUpdateDate
                configurationProvider.configurationLastUpdateCheckDate = currentDate
                await configurationProperties.setConfigurationLastCheckDate(date: currentDate)
                configuration = configurationProvider
                updateConfiguration()
            }
        } else {
            ConfigurationLoader.logger.debug("Cached configuration not found. Initializing default configuration")
            try await loadDefaultConfiguration(cacheDir: configDir)
        }
    }

    public func loadDefaultConfiguration(cacheDir: URL?) async throws {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        guard let confDataURL = bundle.url(
            forResource: CommonsLib.Constants.Configuration.DefaultConfigJson,
            withExtension: nil
        ),
        let confData = try? String(contentsOf: confDataURL) else {
            throw ConfigurationLoaderError.configurationNotFound
        }

        guard let publicKeyURL = bundle.url(
            forResource: CommonsLib.Constants.Configuration.DefaultConfigPub,
            withExtension: nil
        ),
        let publicKey = try? String(contentsOf: publicKeyURL) else {
            throw ConfigurationLoaderError.publicKeyNotFound
        }

        guard let signatureURL = bundle.url(
            forResource: CommonsLib.Constants.Configuration.DefaultConfigRsa,
            withExtension: nil
        ),
        let signatureBytes = try? Data(contentsOf: signatureURL) else {
            throw ConfigurationLoaderError.signatureNotFound
        }

        let signatureText = String(data: signatureBytes, encoding: .utf8) ?? ""

        do {
            try configurationSignatureVerifier
                .verifyConfigurationSignature(config: confData, publicKey: publicKey, signature: signatureText)
        } catch {
            throw ConfigurationLoaderError.configurationVerificationFailed
        }

        try await configurationCache.cacheConfigurationFiles(
            confData: confData,
            publicKey: publicKey,
            signature: signatureText,
            configDir: configDir
        )

        var configurationProvider = try JSONDecoder().decode(
            ConfigurationProvider.self, from: Data(contentsOf: confDataURL)
        )

        ConfigurationLoader.logger.debug(
            "Initializing default configuration version \(configurationProvider.metaInf.serial)"
        )

        await configurationProperties.updateProperties(
            lastUpdateCheck: configurationProvider.configurationLastUpdateCheckDate,
            lastUpdated: configurationProvider.configurationUpdateDate,
            serial: configurationProvider.metaInf.serial
        )

        configurationProvider.configurationLastUpdateCheckDate = await configurationProperties
            .getConfigurationLastCheckDate()
        configurationProvider.configurationUpdateDate = await configurationProperties.getConfigurationUpdatedDate()

        configuration = configurationProvider
        updateConfiguration()
    }

    public func loadCentralConfiguration(cacheDir: URL?) async throws {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        let cachedSignature = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigRsa,
            configDir: configDir
        )

        let currentSignature = try Data(contentsOf: cachedSignature)

        _ = try await loadConfigurationProperty()

        let centralSignature = try await centralConfigurationRepository.fetchSignature().trimmingCharacters(
            in: .whitespaces
        )

        if currentSignature != centralSignature.data(using: .utf8) {
            ConfigurationLoader.logger.debug("Found new configuration")

            let centralConfig = try await centralConfigurationRepository.fetchConfiguration()
            let centralPublicKey = try await centralConfigurationRepository.fetchPublicKey()

            let centralConfigurationProvider = try JSONDecoder().decode(
                ConfigurationProvider.self, from: Data(centralConfig.utf8)
            )

            ConfigurationLoader.logger.debug(
                "Initializing configuration version \(centralConfigurationProvider.metaInf.serial)"
            )

            do {
                try configurationSignatureVerifier.verifyConfigurationSignature(
                    config: centralConfig,
                    publicKey: centralPublicKey,
                    signature: centralSignature
                )
            } catch {
                throw ConfigurationLoaderError.configurationVerificationFailed
            }

            if ConfigurationUtil.isSerialNewerThanCached(
                cachedSerial: configuration?.metaInf.serial ?? 0,
                newSerial: centralConfigurationProvider.metaInf.serial
            ) {
                try await configurationCache.cacheConfigurationFiles(
                    confData: centralConfig,
                    publicKey: centralPublicKey,
                    signature: centralSignature,
                    configDir: configDir
                )

                await configurationProperties.updateProperties(
                    lastUpdateCheck: Date(),
                    lastUpdated: Date(),
                    serial: centralConfigurationProvider.metaInf.serial
                )

                configuration = centralConfigurationProvider
                updateConfiguration()
            } else {
                try await loadCachedConfiguration(afterCentralCheck: true, cacheDir: configDir)
            }
        } else {
            ConfigurationLoader.logger.debug(
                "New configuration not found. Using cached configuration"
            )
            try await loadCachedConfiguration(afterCentralCheck: true, cacheDir: configDir)
        }
    }

    public func shouldCheckForUpdates() async throws -> Bool {
        guard let lastExecutionDate = await configurationProperties.getConfigurationLastCheckDate() else {
            return true
        }

        let currentDate = Date.now
        let daysSinceLastUpdateCheck = lastExecutionDate.daysBetween(currentDate)

        return daysSinceLastUpdateCheck >= 4
    }

    public func getConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error> {
        return AsyncThrowingStream { continuation in
            if self.continuation == nil {
                self.continuation = continuation
            }
        }
    }

    private func updateConfiguration() {
        if let continuation = continuation {
            continuation.yield(configuration)
        }
    }

    private func finishConfigurationUpdate() {
        if let continuation = continuation {
            continuation.finish()
        }
    }
}
