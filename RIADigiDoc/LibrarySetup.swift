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

    @MainActor
    init(
        configurationLoader: ConfigurationLoader? = nil,
        configurationRepository: ConfigurationRepositoryProtocol? = nil
    ) {
        self.configurationLoader = configurationLoader ?? ConfigLibAssembler.shared
            .resolve(ConfigurationLoaderProtocol.self)
        self.configurationRepository = configurationRepository ?? ConfigLibAssembler.shared
            .resolve(ConfigurationRepositoryProtocol.self)
    }

    func setupLibraries() async {
        do {
            try DigiDocConf.observeConfigurationUpdates(configurationRepository: configurationRepository)
            if let schemaDirectory = Directories.getLibraryDirectory() {
                try TSLUtil.setupTSLFiles(destinationDir: schemaDirectory)
            } else {
                LibrarySetup.logger.error("Unable to setup TSL files. Library directory does not exist")
            }
            let configDirectory = try Directories.getCacheDirectory().appendingPathComponent(
                CommonsLib.Constants.Configuration.CacheConfigFolder
            )
            try await configurationLoader.initConfiguration(cacheDir: configDirectory)
            LibrarySetup.logger.debug("Initializing Libdigidocpp")
            try await DigiDocConf.initDigiDoc()
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
}
