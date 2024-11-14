import Foundation
import OSLog
import LibdigidocLibSwift

actor LibrarySetup {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "LibrarySetup")

    func setupLibraries() async {
        do {
            LibrarySetup.logger.debug("Initializing Libdigidocpp")
            try await DigiDocConf.initDigiDoc()
            LibrarySetup.logger.info("Libdigidocpp initialized successfully")
        } catch let error {
            switch error {
            case .initializationFailed(let errorDetail):
                LibrarySetup.logger.error("\(errorDetail.description)")
            default: LibrarySetup.logger.error("Unknown error")
            }
        }
    }
}
