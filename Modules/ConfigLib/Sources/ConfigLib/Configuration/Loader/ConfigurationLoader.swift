/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import CommonsLib
import FactoryKit
import Foundation
import UtilsLib

public actor ConfigurationLoader: ConfigurationLoaderProtocol, Loggable {
    private var configuration: ConfigurationProvider?

    public typealias ConfigStream = AsyncThrowingStream<ConfigurationProvider?, Error>
    private var continuations: [UUID: ConfigStream.Continuation] = [:]
    private var latestConfiguration: ConfigurationProvider?

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

    public func initConfiguration(
        configDir: URL,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws {
        ConfigurationLoader.logger().info("Initializing configuration")

        if !fileManager.fileExists(atPath: configDir.resolvedPath) {
            try fileManager.createDirectory(
                at: configDir, withIntermediateDirectories: true, attributes: nil)
        }

        try await loadLocalConfiguration(configDir: configDir)

        try await loadConfigurationProperty()

        if try await shouldCheckForUpdates() {
            ConfigurationLoader.logger().info("Checking for configuration updates...")
            do {
                try await loadCentralConfiguration(
                    cacheDir: configDir,
                    proxyInfo: proxyInfo,
                    userAgent: userAgent
                )
            } catch {
                try await loadLocalConfiguration(configDir: configDir)
            }
        }

        ConfigurationLoader.logger().info("Finished initializing configuration")

        finishConfigurationUpdate()
    }

    public func getConfiguration() -> ConfigurationProvider? {
        return configuration
    }

    @discardableResult
    public func loadConfigurationProperty() async throws -> ConfigurationProperty {
        let properties =
            try await configurationProperties
            .getConfigurationProperties(
                from: URL(
                    fileURLWithPath: bundle.path(
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

        let confFile = configDir.appending(
            path: CommonsLib.Constants.Configuration.CachedConfigJson
        )

        guard
            let publicKeyURL = bundle.url(
                forResource: CommonsLib.Constants.Configuration.DefaultConfigEcPub,
                withExtension: nil
            ),
            let publicKey = try? String(contentsOf: publicKeyURL, encoding: .utf8)
        else {
            throw ConfigurationLoaderError.publicKeyNotFound
        }

        let signatureFile = configDir.appending(
            path: CommonsLib.Constants.Configuration.CachedConfigEcc
        )

        let configFilesExist =
            fileManager.fileExists(atPath: confFile.resolvedPath) &&
            fileManager.fileExists(atPath: signatureFile.resolvedPath)

        if configFilesExist {
            ConfigurationLoader.logger().info("Initializing cached configuration")

            let confFileContents = try String(contentsOf: confFile, encoding: .utf8)
            let signatureContents = try String(contentsOf: signatureFile, encoding: .utf8)

            try configurationSignatureVerifier.verifyConfigurationSignature(
                config: confFileContents,
                publicKey: publicKey,
                signature: signatureContents
            )

            var configurationProvider = try JSONDecoder().decode(
                ConfigurationProvider.self,
                from: Data(contentsOf: confFile)
            )

            ConfigurationLoader.logger().info(
                "Using cached configuration version \(configurationProvider.metaInf.serial)"
            )

            try await configurationCache.cacheConfigurationFiles(
                confData: confFileContents,
                signature: signatureContents,
                configDir: configDir
            )

            if !afterCentralCheck {
                await configurationProperties.updateProperties(
                    lastUpdateCheck: configurationProvider.configurationLastUpdateCheckDate,
                    lastUpdated: configurationProvider.configurationUpdateDate,
                    serial: configurationProvider.metaInf.serial
                )

                configurationProvider.configurationLastUpdateCheckDate =
                    await configurationProperties
                    .getConfigurationLastCheckDate()
                configurationProvider.configurationUpdateDate =
                    await configurationProperties
                    .getConfigurationUpdatedDate()

                configuration = configurationProvider
                updateConfiguration(configurationProvider)
            } else {
                let currentDate = Date()
                configurationProvider.configurationUpdateDate =
                    configurationProvider.configurationUpdateDate
                    ?? configuration?.configurationUpdateDate
                configurationProvider.configurationLastUpdateCheckDate = currentDate
                await configurationProperties.setConfigurationLastCheckDate(date: currentDate)
                configuration = configurationProvider
                updateConfiguration(configurationProvider)
            }
        } else {
            ConfigurationLoader.logger().info(
                "Cached configuration not found. Initializing default configuration")
            try await loadDefaultConfiguration(cacheDir: configDir)
        }
    }

    public func loadDefaultConfiguration(cacheDir: URL?) async throws {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        guard
            let confDataURL = bundle.url(
                forResource: CommonsLib.Constants.Configuration.DefaultConfigJson,
                withExtension: nil
            ),
            let confData = try? String(contentsOf: confDataURL, encoding: .utf8)
        else {
            throw ConfigurationLoaderError.configurationNotFound
        }

        guard
            let publicKeyURL = bundle.url(
                forResource: CommonsLib.Constants.Configuration.DefaultConfigEcPub,
                withExtension: nil
            ),
            let publicKey = try? String(contentsOf: publicKeyURL, encoding: .utf8)
        else {
            throw ConfigurationLoaderError.publicKeyNotFound
        }

        guard
            let signatureURL = bundle.url(
                forResource: CommonsLib.Constants.Configuration.DefaultConfigEcc,
                withExtension: nil
            ),
            let signatureBytes = try? Data(contentsOf: signatureURL)
        else {
            throw ConfigurationLoaderError.signatureNotFound
        }

        let signatureText = String(data: signatureBytes, encoding: .utf8) ?? ""

        do {
            try configurationSignatureVerifier
                .verifyConfigurationSignature(
                    config: confData, publicKey: publicKey, signature: signatureText)
        } catch {
            throw ConfigurationLoaderError.configurationVerificationFailed
        }

        try await configurationCache.cacheConfigurationFiles(
            confData: confData,
            signature: signatureText,
            configDir: configDir
        )

        var configurationProvider = try JSONDecoder().decode(
            ConfigurationProvider.self, from: Data(contentsOf: confDataURL)
        )

        ConfigurationLoader.logger().info(
            "Initializing default configuration version \(configurationProvider.metaInf.serial)"
        )

        await configurationProperties.updateProperties(
            lastUpdateCheck: configurationProvider.configurationLastUpdateCheckDate,
            lastUpdated: configurationProvider.configurationUpdateDate,
            serial: configurationProvider.metaInf.serial
        )

        configurationProvider.configurationLastUpdateCheckDate =
            await configurationProperties
            .getConfigurationLastCheckDate()
        configurationProvider.configurationUpdateDate =
            await configurationProperties.getConfigurationUpdatedDate()

        configuration = configurationProvider
        updateConfiguration(configurationProvider)
    }

    public func loadCentralConfiguration(
        cacheDir: URL?,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        let cachedSignature = try await configurationCache.getCachedFile(
            fileName: CommonsLib.Constants.Configuration.CachedConfigEcc,
            configDir: configDir
        )

        let currentSignature = try Data(contentsOf: cachedSignature)

        _ = try await loadConfigurationProperty()

        var centralSignature = ""

        centralSignature = try await centralConfigurationRepository.fetchSignature(
            proxyInfo: proxyInfo,
            userAgent: userAgent
        ).trimmingCharacters(in: .whitespaces)

        if !centralSignature.isEmpty && currentSignature != centralSignature.data(using: .utf8) {
            ConfigurationLoader.logger().info("Found new configuration")

            let centralConfig = try await centralConfigurationRepository.fetchConfiguration(
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )

            let centralConfigurationProvider = try JSONDecoder().decode(
                ConfigurationProvider.self, from: Data(centralConfig.utf8)
            )
            ConfigurationLoader.logger().info(
                "Initializing configuration version \(centralConfigurationProvider.metaInf.serial)"
            )

            guard
                let publicKeyURL = bundle.url(
                    forResource: CommonsLib.Constants.Configuration.DefaultConfigEcPub,
                    withExtension: nil
                ),
                let publicKey = try? String(contentsOf: publicKeyURL, encoding: .utf8)
            else {
                throw ConfigurationLoaderError.publicKeyNotFound
            }

            do {
                try configurationSignatureVerifier.verifyConfigurationSignature(
                    config: centralConfig,
                    publicKey: publicKey,
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
                    signature: centralSignature,
                    configDir: configDir
                )

                await configurationProperties.updateProperties(
                    lastUpdateCheck: Date(),
                    lastUpdated: Date(),
                    serial: centralConfigurationProvider.metaInf.serial
                )

                configuration = centralConfigurationProvider

                configuration?.configurationLastUpdateCheckDate =
                    await configurationProperties.getConfigurationLastCheckDate()
                configuration?.configurationUpdateDate =
                    await configurationProperties.getConfigurationUpdatedDate()

                updateConfiguration(configuration)

            } else {
                try await loadCachedConfiguration(afterCentralCheck: true, cacheDir: configDir)
            }
        } else {
            ConfigurationLoader.logger().info(
                "New configuration not found. Using cached configuration"
            )
            try await loadCachedConfiguration(afterCentralCheck: true, cacheDir: configDir)
        }
    }

    public func shouldCheckForUpdates() async throws -> Bool {
        guard let lastExecutionDate = await configurationProperties.getConfigurationLastCheckDate()
        else {
            return true
        }

        let currentDate = Date.now
        let daysSinceLastUpdateCheck = lastExecutionDate.daysBetween(currentDate)

        return daysSinceLastUpdateCheck >= 4
    }

    public func getConfigurationUpdates(replayLatest: Bool = true) -> ConfigStream {
        AsyncThrowingStream { continuation in
            let token = UUID()
            continuations[token] = continuation

            if replayLatest, let config = latestConfiguration {
                continuation.yield(config)
            }

            continuation.onTermination = { @Sendable _ in
                Task { [weak self] in
                    await self?.removeContinuation(token)
                }
            }
        }
    }

    private func loadLocalConfiguration(configDir: URL) async throws {
        // Load default configuration if cached configuration does not succeed
        do {
            try await loadCachedConfiguration(afterCentralCheck: false, cacheDir: configDir)
        } catch {
            try await loadDefaultConfiguration(cacheDir: configDir)
        }
    }

    private func updateConfiguration(_ configuration: ConfigurationProvider?) {
        latestConfiguration = configuration
        for continuation in continuations.values {
            continuation.yield(configuration)
        }
    }

    private func finishConfigurationUpdate(with error: Error? = nil) {
        for continuation in continuations.values {
            if let error {
                continuation.finish(throwing: error)
            } else {
                continuation.finish()
            }
        }
        continuations.removeAll()
    }

    private func removeContinuation(_ token: UUID) {
        continuations.removeValue(forKey: token)
    }
}
