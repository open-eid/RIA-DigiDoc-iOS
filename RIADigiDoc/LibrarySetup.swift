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

    init(
        configurationLoader: ConfigurationLoaderProtocol,
        configurationRepository: ConfigurationRepositoryProtocol,
        fileManager: FileManagerProtocol,
        tslUtil: TSLUtilProtocol,
    ) {
        self.configurationLoader = configurationLoader
        self.configurationRepository = configurationRepository
        self.fileManager = fileManager
        self.tslUtil = tslUtil
    }

    func setupLibraries() async {
        do {
            try DigiDocConf.observeConfigurationUpdates(configurationRepository: configurationRepository)
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
