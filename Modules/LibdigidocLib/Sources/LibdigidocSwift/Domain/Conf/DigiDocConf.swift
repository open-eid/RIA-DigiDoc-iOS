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
import FactoryKit
import LibdigidocLibObjC
import ConfigLib
import UtilsLib
import CommonsLib

public struct DigiDocConf: DigiDocConfProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "DigiDocConf")

    @MainActor static let sharedInitializer = DigiDocInitializer(
        configurationRepository: Container.shared.configurationRepository(),
        fileManager: Container.shared.fileManager()
    )

    public static func initDigiDoc(
        configuration: ConfigurationProvider? = nil,
        sivaUrl: String? = nil,
        sivaCert: Data? = nil,
        tsaUrl: String? = nil,
        tsCert: Data? = nil
    ) async throws {
        try await sharedInitializer.initializeDigiDoc(configuration: configuration)

        if let sivaUrl = sivaUrl {
            await setSiVaUrl(sivaUrl)
        }

        if let sivaCert = sivaCert {
            await addSiVaCert(sivaCert)
        }

        if let tsaUrl = tsaUrl {
            await setTSUrl(tsaUrl)
        }

        if let tsCert = tsCert {
            await addTSCert(tsCert)
        }
    }

    public static func observeConfigurationUpdates(configurationRepository: ConfigurationRepositoryProtocol) throws {
        Task {
            guard let configStream = await configurationRepository.observeConfigurationUpdates() else {
                logger.error("Unable to get configuration updates stream")
                return
            }
            do {
                for try await config in configStream {
                    try await sharedInitializer.overrideConfiguration(newConfig: config)
                }
            } catch {
                logger.error("Unable to override configuration updates: \(error)")
            }
        }
    }

    public static func setSiVaUrl(_ url: String) async {
        if url.isEmpty { return }
        DigiDocConfWrapper.sharedInstance()?.setSiVaUrl(url)
    }

    public static func addSiVaCert(_ cert: Data) async {
        DigiDocConfWrapper.sharedInstance()?.addSiVaCert(cert)
    }

    public static func setTSUrl(_ url: String) async {
        DigiDocConfWrapper.sharedInstance()?.setTSUrl(url)
    }

    public static func addTSCert(_ cert: Data) async {
        DigiDocConfWrapper.sharedInstance()?.addTSCert(cert)
    }
}

public actor DigiDocInitializer {
    private var isInitialized = false
    private var initializationError: ErrorDetail?

    private let configurationRepository: ConfigurationRepositoryProtocol
    private let fileManager: FileManagerProtocol

    private static let libdigidocppLogLevel = 4

    private var digidocConf = DigiDocConfig()

    @MainActor
    init(
        configurationRepository: ConfigurationRepositoryProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.configurationRepository = configurationRepository
        self.fileManager = fileManager
    }

    func initializeDigiDoc(configuration: ConfigurationProvider? = nil) async throws {

        guard !isInitialized else {
            throw DigiDocError.alreadyInitialized
        }

        if let customConf = configuration {
            try await initDigiDoc(
                conf: toDigiDocConfig(
                    logLevel: DigiDocInitializer.libdigidocppLogLevel,
                    logFile: overrideLogFile(),
                    tslCache: overrideTSLCache(),
                    configurationProvider: customConf
                )
            )
        } else {
            try await initDigiDoc(conf: digidocConf)
        }
        isInitialized = true
    }

    func toDigiDocConfig(
        logLevel: Int,
        logFile: String,
        tslCache: String,
        configurationProvider: ConfigurationProvider
    ) -> DigiDocConfig {
        let digiDocConfiguration = DigiDocConfig()
        digiDocConfiguration.logLevel = overrideLogLevel(logLevel: logLevel)
        digiDocConfiguration.logFile = logFile
        digiDocConfiguration.tslcache = tslCache
        digiDocConfiguration.tslurl = overrideTSLUrl(conf: configurationProvider)
        digiDocConfiguration.tslcerts = overrideTSLCerts(conf: configurationProvider)
        digiDocConfiguration.tsaurl = overrideTSAUrl(conf: configurationProvider)
        digiDocConfiguration.sivaurl = overrideSiVaUrl(conf: configurationProvider)
        digiDocConfiguration.ocspissuers = overrideOCSPIssuers(conf: configurationProvider)
        digiDocConfiguration.certbundle = overrideCertBundle(conf: configurationProvider)

        return digiDocConfiguration
    }

    func overrideConfiguration(newConfig: ConfigurationProvider?) async throws {
        let configuration = await newConfig != nil ? newConfig : configurationRepository.getConfiguration()

        guard let conf = configuration else {
            throw DigiDocError.initializationFailed(
                ErrorDetail(message: "Unable to get configuration")
            )
        }

        digidocConf = toDigiDocConfig(
            logLevel: DigiDocInitializer.libdigidocppLogLevel,
            logFile: overrideLogFile(),
            tslCache: overrideTSLCache(),
            configurationProvider: conf
        )

        if isInitialized {
            DigiDocConfWrapper.sharedInstance()?.updateConfiguration(digidocConf)
        }
    }

    private func overrideLogLevel(logLevel: Int) -> Int32 {
        return Int32(logLevel)
    }

    private func overrideLogFile() -> String {
        do {
            return try Directories
                .getLibdigidocLogFile(
                    from: Directories.getLibraryDirectory(fileManager: fileManager),
                    fileManager: fileManager
                )?.path ?? ""
        } catch {
            return ""
        }
    }

    private func overrideTSLCache() -> String {
        return Directories.getTslCacheDirectory(fileManager: fileManager)?.path ?? ""
    }

    private func overrideTSLUrl(conf: ConfigurationProvider) -> URL {
        return conf.tslUrl
    }

    private func overrideTSLCerts(conf: ConfigurationProvider) -> [Data] {
        return conf.tslCerts
    }

    private func overrideTSAUrl(conf: ConfigurationProvider) -> URL {
        return conf.tsaUrl
    }

    private func overrideSiVaUrl(conf: ConfigurationProvider) -> URL {
        return conf.sivaUrl
    }

    private func overrideOCSPIssuers(conf: ConfigurationProvider) -> [String: String] {
        return conf.ocspIssuers
    }

    private func overrideCertBundle(conf: ConfigurationProvider) -> [Data] {
        return conf.certBundle
    }

    private func overrideLDAPCerts(conf: ConfigurationProvider) -> [Data] {
        return conf.ldapCerts
    }

    private func initDigiDoc(
        conf digiDocConf: DigiDocConfig,
        digidocConfWrapper: DigiDocConfWrapper = DigiDocConfWrapper()
    ) async throws {
        do {
            let isInitialized = try await digidocConfWrapper.initWithConf(digiDocConf)

            guard isInitialized, DigiDocConfWrapper.sharedInstance() != nil else {
                throw DigiDocError.initializationFailed(
                    ErrorDetail(message: "Unable to initialize Libdigidocpp with configuration")
                )
            }
        } catch {
            if let nsError = error as NSError? {
                throw DigiDocError.initializationFailed(ErrorDetail(nsError: nsError))
            } else {
                throw error
            }
        }
    }
}
