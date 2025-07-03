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

    public static func initDigiDoc(configuration: ConfigurationProvider? = nil) async throws {
        try await sharedInitializer.initializeDigiDoc(configuration: configuration)
    }

    public static func observeConfigurationUpdates(configurationRepository: ConfigurationRepositoryProtocol) throws {
        Task {
            guard let configStream = await configurationRepository.observeConfigurationUpdates() else {
                logger.error("Unable to get configuration updates stream")
                return
            }
            for try await config in configStream {
                try await sharedInitializer.overrideConfiguration(newConfig: config)
            }
        }
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

    private func overrideTSLUrl(conf: ConfigurationProvider) -> String {
        return conf.tslUrl
    }

    private func overrideTSLCerts(conf: ConfigurationProvider) -> [String] {
        return conf.tslCerts
    }

    private func overrideTSAUrl(conf: ConfigurationProvider) -> String {
        return conf.tsaUrl
    }

    private func overrideSiVaUrl(conf: ConfigurationProvider) -> String {
        return conf.sivaUrl
    }

    private func overrideOCSPIssuers(conf: ConfigurationProvider) -> [String: String] {
        return conf.ocspUrls
    }

    private func overrideCertBundle(conf: ConfigurationProvider) -> [String] {
        return conf.certBundle
    }

    private func initDigiDoc(
        conf digiDocConf: DigiDocConfig,
        digidocConfWrapper: DigiDocConfWrapper = DigiDocConfWrapper()
    ) async throws {

        var errorDetail: ErrorDetail?

        let lock = NSLock()
        let isInitialized: Bool = try await withCheckedThrowingContinuation { continuation in
            digidocConfWrapper.initWithConf(digiDocConf) { success, error in
                lock.lock()
                defer { lock.unlock() }
                if let error = error as NSError? {
                    errorDetail = ErrorDetail(nsError: error)
                    continuation
                        .resume(
                            throwing: DigiDocError.initializationFailed(
                                errorDetail ?? ErrorDetail()
                            )
                        )
                } else {
                    continuation.resume(returning: success)
                }
            }
        }

        guard isInitialized, DigiDocConfWrapper.sharedInstance() != nil else {
            throw DigiDocError.initializationFailed(errorDetail ?? ErrorDetail())
        }
    }
}
