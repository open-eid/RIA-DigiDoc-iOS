import Foundation
import LibdigidoclibSwift
import OSLog

actor LibrarySetup {
    static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "LibrarySetup")

    func setupLibraries() async {
        do {
            LibrarySetup.logger.debug("Initializing Libdigidocpp")
            try await DigiDocConf.initDigiDoc()
            LibrarySetup.logger.info("Libdigidocpp initialized successfully")
        } catch let error {
            switch error {
            case .initializationFailed(let message): LibrarySetup.logger.error("\(message)")
            }
        }
    }
}
