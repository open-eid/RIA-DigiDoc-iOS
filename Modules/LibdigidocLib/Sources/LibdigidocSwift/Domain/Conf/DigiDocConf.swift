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

import Foundation
import FactoryKit
import LibdigidocLibObjC
import ConfigLib
import UtilsLib
import CommonsLib

public struct DigiDocConf: DigiDocConfProtocol, Loggable {

    @MainActor static let sharedInitializer = DigiDocInitializer(
        configurationRepository: Container.shared.configurationRepository(),
        fileManager: Container.shared.fileManager()
    )

    public static func initDigiDoc(
        configuration: ConfigurationProvider? = nil,
        isLoggingEnabled: Bool = false,
        tsaOption: ServicesSettingsOption? = nil,
        tsaUrl: URL? = nil,
        tsaCert: Data? = nil,
        sivaOption: ServicesSettingsOption? = nil,
        sivaUrl: URL? = nil,
        sivaCert: Data? = nil,
        proxyInfo: ProxyInfo? = nil,
        userAgent: String
    ) async throws {
        try await sharedInitializer.initializeDigiDoc(
            configuration: configuration,
            isLoggingEnabled: isLoggingEnabled,
            userAgent: userAgent
        )

        if let tsaOption {
            setTSAInfo(url: tsaUrl, cert: tsaCert, option: tsaOption, isInit: true)
        }
        if let sivaOption {
            setSiVaInfo(url: sivaUrl, cert: sivaCert, option: sivaOption, isInit: true)
        }
        setProxyInfo(proxyInfo: proxyInfo, isInit: true)
    }

    public static func observeConfigurationUpdates(
        configurationRepository: ConfigurationRepositoryProtocol,
    ) throws {
        Task {
            guard let configStream = await configurationRepository.observeConfigurationUpdates(
            ) else {
                logger().error("Unable to get configuration updates stream")
                return
            }
            do {
                for try await config in configStream {
                    try await sharedInitializer.overrideConfiguration(newConfig: config)
                }
            } catch {
                logger().error("Unable to override configuration updates: \(error)")
            }
        }
    }

    public static func restoreDefaultSettings() async {
        DigiDocConfWrapper.sharedInstance()?.setProxyHost(nil)
        DigiDocConfWrapper.sharedInstance()?.setProxyPort(nil)
        DigiDocConfWrapper.sharedInstance()?.setProxyUser(nil)
        DigiDocConfWrapper.sharedInstance()?.setProxyPass(nil)
        DigiDocConfWrapper.sharedInstance()?.addSiVaCert(nil)
        DigiDocConfWrapper.sharedInstance()?.addTSCert(nil)
        DigiDocConfWrapper.sharedInstance()?.setSiVaUrl(nil)
        DigiDocConfWrapper.sharedInstance()?.setTSUrl(nil)
    }

    public static func setProxyInfo(proxyInfo: ProxyInfo?, isInit: Bool = false) {
        if let proxyInfo, proxyInfo.option != .disabled {
            DigiDocConfWrapper.sharedInstance()?.setProxyHost(proxyInfo.host)
            let portString = String(proxyInfo.port)
            DigiDocConfWrapper.sharedInstance()?.setProxyPort(portString)
            DigiDocConfWrapper.sharedInstance()?.setProxyUser(proxyInfo.username)
            DigiDocConfWrapper.sharedInstance()?.setProxyPass(proxyInfo.password)
            return
        }
        if isInit { return }
        DigiDocConfWrapper.sharedInstance()?.setProxyHost(nil)
        DigiDocConfWrapper.sharedInstance()?.setProxyPort(nil)
        DigiDocConfWrapper.sharedInstance()?.setProxyUser(nil)
        DigiDocConfWrapper.sharedInstance()?.setProxyPass(nil)
    }

    public static func setSiVaInfo(
        url: URL?,
        cert: Data?,
        option: ServicesSettingsOption,
        isInit: Bool = false
    ) {
        setSiVaUrl(url: url, option: option, isInit: isInit)
        addSiVaCert(cert: cert, option: option, isInit: isInit)
    }

    public static func setTSAInfo(
        url: URL?,
        cert: Data?,
        option: ServicesSettingsOption,
        isInit: Bool = false
    ) {
        setTSAUrl(url: url, option: option, isInit: isInit)
        addTSACert(cert: cert, option: option, isInit: isInit)
    }

    private static func setTSAUrl(url: URL?, option: ServicesSettingsOption, isInit: Bool = false) {
        if option == .manualSetting {
            if let url, url.absoluteString.isEmpty == false {
                DigiDocConfWrapper.sharedInstance()?.setTSUrl(url)
                return
            }
        }
        if isInit { return }
        DigiDocConfWrapper.sharedInstance()?.setTSUrl(nil)
    }

    private static func addTSACert(cert: Data?, option: ServicesSettingsOption, isInit: Bool = false) {
        if option == .manualSetting {
            if let cert, cert.isEmpty == false {
                DigiDocConfWrapper.sharedInstance()?.addTSCert(cert)
                return
            }
        }
        if isInit { return }
        DigiDocConfWrapper.sharedInstance()?.addTSCert(nil)
    }

    private static func setSiVaUrl(url: URL?, option: ServicesSettingsOption, isInit: Bool = false) {
        if option == .manualSetting {
            if let url, url.absoluteString.isEmpty == false {
                DigiDocConfWrapper.sharedInstance()?.setSiVaUrl(url)
                return
            }
        }
        if isInit { return }
        DigiDocConfWrapper.sharedInstance()?.setSiVaUrl(nil)
    }

    private static func addSiVaCert(cert: Data?, option: ServicesSettingsOption, isInit: Bool = false) {
        if option == .manualSetting {
            if let cert, cert.isEmpty == false {
                DigiDocConfWrapper.sharedInstance()?.addSiVaCert(cert)
                return
            }
        }
        if isInit { return }
        DigiDocConfWrapper.sharedInstance()?.addSiVaCert(nil)
    }
}

public actor DigiDocInitializer: Loggable {
    private var isInitialized = false
    private var initializationError: ErrorDetail?
    private var isInitializing = false
    private var initializationWaiters: [CheckedContinuation<Void, Error>] = []

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

    func initializeDigiDoc(
        configuration: ConfigurationProvider? = nil,
        isLoggingEnabled: Bool,
        userAgent: String
    ) async throws {

        if isInitialized {
            throw DigiDocError.alreadyInitialized
        }

        if isInitializing {
            try await withCheckedThrowingContinuation { continuation in
                initializationWaiters.append(continuation)
            }
            throw DigiDocError.alreadyInitialized
        }

        isInitializing = true

        let logLevel = isLoggingEnabled ? DigiDocInitializer.libdigidocppLogLevel : 0

        do {
            if let customConf = configuration {
                try await initDigiDoc(
                    conf: toDigiDocConfig(
                        logLevel: logLevel,
                        logFile: overrideLogFile(),
                        tslCache: overrideTSLCache(),
                        configurationProvider: customConf
                    ),
                    userAgent: userAgent
                )
            } else {
                digidocConf.logLevel = overrideLogLevel(logLevel: logLevel)
                digidocConf.logFile = overrideLogFile()
                digidocConf.tslcache = overrideTSLCache()
                try await initDigiDoc(conf: digidocConf, userAgent: userAgent)
            }
            isInitialized = true
            isInitializing = false
            let waiters = initializationWaiters
            initializationWaiters.removeAll()
            waiters.forEach { $0.resume() }
        } catch {
            isInitializing = false
            let waiters = initializationWaiters
            initializationWaiters.removeAll()
            waiters.forEach { $0.resume(throwing: error) }
            throw error
        }
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
        digiDocConfiguration.certbundle = overrideCertBundle(conf: configurationProvider)
        digiDocConfiguration.ldapcerts = overrideLDAPCerts(conf: configurationProvider)

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
                )?.resolvedPath ?? ""
        } catch {
            return ""
        }
    }

    private func overrideTSLCache() -> String {
        return Directories.getTslCacheDirectory(fileManager: fileManager)?.resolvedPath ?? ""
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

    private func overrideCertBundle(conf: ConfigurationProvider) -> [Data] {
        return conf.certBundle
    }

    private func overrideLDAPCerts(conf: ConfigurationProvider) -> [Data] {
        return conf.ldapCerts
    }

    private func initDigiDoc(
        conf digiDocConf: DigiDocConfig,
        digidocConfWrapper: DigiDocConfWrapper = DigiDocConfWrapper(),
        userAgent: String
    ) async throws {
        do {
            let isInitialized = try await digidocConfWrapper.initWithConf(digiDocConf, userAgent: userAgent)

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
