/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

import Foundation
import FactoryKit
import LibdigidocLibSwift
import CryptoObjCWrapper
import CryptoSwift
import ConfigLib
import CommonsLib
import UtilsLib

actor LibrarySetup: Loggable {
    private let configurationLoader: ConfigurationLoaderProtocol
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let fileManager: FileManagerProtocol
    private let tslUtil: TSLUtilProtocol
    private let dataStore: DataStoreProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let keychainStore: KeychainStoreProtocol
    private let proxyUtil: ProxyUtilProtocol
    private let cryptoSetup: CryptoSetupProtocol
    private let userAgentUtil: UserAgentUtilProtocol

    init(
        configurationLoader: ConfigurationLoaderProtocol,
        configurationRepository: ConfigurationRepositoryProtocol,
        fileManager: FileManagerProtocol,
        tslUtil: TSLUtilProtocol,
        dataStore: DataStoreProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol,
        keychainStore: KeychainStoreProtocol,
        proxyUtil: ProxyUtilProtocol,
        cryptoSetup: CryptoSetupProtocol,
        userAgentUtil: UserAgentUtilProtocol
    ) {
        self.configurationLoader = configurationLoader
        self.configurationRepository = configurationRepository
        self.fileManager = fileManager
        self.tslUtil = tslUtil
        self.dataStore = dataStore
        self.advancedSettingsRepository = advancedSettingsRepository
        self.keychainStore = keychainStore
        self.proxyUtil = proxyUtil
        self.cryptoSetup = cryptoSetup
        self.userAgentUtil = userAgentUtil
    }

    func setupLibraries() async {
        let isLoggingEnabled = await dataStore.getIsLoggingEnabled()
        await initializeLogging(isLoggingEnabled: isLoggingEnabled)

        do {
            let proxyInfo = await proxyUtil.getProxyInfo()
            let appLanguage = await dataStore.getSelectedLanguage()
            let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: appLanguage)

            try DigiDocConf.observeConfigurationUpdates(
                configurationRepository: configurationRepository
            )

            if let schemaDirectory = Directories.getLibraryDirectory(fileManager: fileManager) {
                try tslUtil.setupTSLFiles(tsls: [], destinationDir: schemaDirectory)
            } else {
                LibrarySetup.logger().error("Unable to setup TSL files. Library directory does not exist")
            }
            let configDirectory = try Directories.getCacheDirectory(
                fileManager: fileManager
            ).appending(path:
                CommonsLib.Constants.Configuration.CacheConfigFolder
            )

            // Make sure "initDigiDoc" is still run even if configuration has an error
            do {
                try await configurationLoader.initConfiguration(
                    cacheDir: configDirectory,
                    proxyInfo: proxyInfo,
                    userAgent: userAgent
                )
            } catch {
                LibrarySetup.logger().error("Unable to initialize configuration: \(error)")
            }

            LibrarySetup.logger().debug("Initializing Libdigidocpp")
            try await DigiDocConf.initDigiDoc(
                isLoggingEnabled: isLoggingEnabled,
                tsaOption: getTSAOption(),
                tsaUrl: getTSAUrl(),
                tsaCert: getTSACert(),
                sivaOption: getSiVaOption(),
                sivaUrl: getSiVaUrl(),
                sivaCert: getSiVaCert(),
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )
            LibrarySetup.logger().info("Libdigidocpp initialized successfully")

            await CryptoContainer.enableLogging(bool: isLoggingEnabled)

            let configurationProvider = await configurationRepository.getConfiguration()

            await cryptoSetup.setLdapConfig(configurationProvider)
            await cryptoSetup.setCdoc2Config(configurationProvider)
            await cryptoSetup.setCdoc2Settings(configurationProvider)

            try saveLDAPCertsToLibrary(ldapCertsBundle: configurationProvider?.ldapCerts)
        } catch let error {
            switch error {
            case DigiDocError.initializationFailed(let errorDetail):
                LibrarySetup.logger().error("\(errorDetail.description)")
            case DigiDocError.alreadyInitialized:
                LibrarySetup.logger().error("Cannot initialize Libdigidocpp: Already initialized")
            default: LibrarySetup.logger().error(
                "Unknown initialization error: \(error.localizedDescription). Error: \(error)")
            }
        }
    }

    private func saveLDAPCertsToLibrary(
        ldapCertsBundle: [Data]?
    ) throws {
        guard let ldapCerts = ldapCertsBundle else {
            return
        }

        let libraryDir = try fileManager.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let certsDir = libraryDir
            .appending(path: Constants.Folder.LDAPCerts)

        if !fileManager.fileExists(atPath: certsDir.path) {
            try fileManager.createDirectory(
                at: certsDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        let pemString = ldapCerts.map { certData -> String in
            let base64 = certData.base64EncodedString(options: [.lineLength64Characters])
            return """
            -----BEGIN CERTIFICATE-----
            \(base64)
            -----END CERTIFICATE-----
            """
        }.joined(separator: "\n\n")

        let pemURL = certsDir.appendingPathComponent(Constants.File.LDAPCertsPem)

        try pemString.write(
            to: pemURL,
            atomically: true,
            encoding: .utf8
        )
    }

    private func initializeLogging(isLoggingEnabled: Bool) async {
        Container.shared.isLoggingEnabled.register { isLoggingEnabled }
    }

    private func getTSAOption() async -> ServicesSettingsOption {
        return await dataStore.getTSAUrlOption()
    }

    private func getTSAUrl() async -> URL? {
        let urlString = await dataStore.getTSAUrl()
        return URL(string: urlString)
    }

    private func getTSACert() async -> Data? {
        return await advancedSettingsRepository.getCertificate(
            certificateFolder: CommonsLib.Constants.Folder.TSACert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.TSACert,
        )
    }

    private func getSiVaOption() async -> ServicesSettingsOption {
        return await dataStore.getValidationServiceOption()
    }

    private func getSiVaUrl() async -> URL? {
        let urlString = await dataStore.getValidationServiceURL()
        return URL(string: urlString)
    }

    private func getSiVaCert() async -> Data? {
        return await advancedSettingsRepository.getCertificate(
            certificateFolder: CommonsLib.Constants.Folder.SiVaCert,
            certificateBaseName: CommonsLib.Constants.FileBaseName.SiVaCert,
        )
    }
}
