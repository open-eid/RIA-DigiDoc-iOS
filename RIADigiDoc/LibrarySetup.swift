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
import OSLog
import LibdigidocLibSwift
import ConfigLib
import CommonsLib
import UtilsLib

actor LibrarySetup {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "LibrarySetup")

    private let configurationLoader: ConfigurationLoaderProtocol
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let fileManager: FileManagerProtocol
    private let tslUtil: TSLUtilProtocol
    private let dataStore: DataStoreProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let keychainStore: KeychainStoreProtocol
    private let proxyUtil: ProxyUtilProtocol

    init(
        configurationLoader: ConfigurationLoaderProtocol,
        configurationRepository: ConfigurationRepositoryProtocol,
        fileManager: FileManagerProtocol,
        tslUtil: TSLUtilProtocol,
        dataStore: DataStoreProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol,
        keychainStore: KeychainStoreProtocol,
        proxyUtil: ProxyUtilProtocol
    ) {
        self.configurationLoader = configurationLoader
        self.configurationRepository = configurationRepository
        self.fileManager = fileManager
        self.tslUtil = tslUtil
        self.dataStore = dataStore
        self.advancedSettingsRepository = advancedSettingsRepository
        self.keychainStore = keychainStore
        self.proxyUtil = proxyUtil
    }

    func setupLibraries() async {
        do {
            let proxyInfo = await proxyUtil.getProxyInfo()

            try DigiDocConf.observeConfigurationUpdates(
                configurationRepository: configurationRepository
            )
            if let schemaDirectory = Directories.getLibraryDirectory(fileManager: fileManager) {
                try tslUtil.setupTSLFiles(tsls: [], destinationDir: schemaDirectory)
            } else {
                LibrarySetup.logger.error("Unable to setup TSL files. Library directory does not exist")
            }
            let configDirectory = try Directories.getCacheDirectory(
                fileManager: fileManager
            ).appendingPathComponent(
                CommonsLib.Constants.Configuration.CacheConfigFolder
            )
            try await configurationLoader.initConfiguration(
                cacheDir: configDirectory,
                proxyInfo: proxyInfo
            )
            LibrarySetup.logger.debug("Initializing Libdigidocpp")
            try await DigiDocConf.initDigiDoc(
                tsaOption: getTSAOption(),
                tsaUrl: getTSAUrl(),
                tsaCert: getTSACert(),
                sivaOption: getSiVaOption(),
                sivaUrl: getSiVaUrl(),
                sivaCert: getSiVaCert(),
                proxyInfo: proxyInfo
            )
            LibrarySetup.logger.info("Libdigidocpp initialized successfully")
        } catch let error {
            switch error {
            case DigiDocError.initializationFailed(let errorDetail):
                LibrarySetup.logger.error("\(errorDetail.description)")
            case DigiDocError.alreadyInitialized:
                LibrarySetup.logger.error("Cannot initialize Libdigidocpp: Already initialized")
            default: LibrarySetup.logger.error(
                "Unknown initialization error: \(error.localizedDescription). Error: \(error)")
            }
        }
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
