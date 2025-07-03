import Foundation
import OSLog
import FactoryKit
import UtilsLib
import CommonsLib

@MainActor
class ContentViewModel: ContentViewModelProtocol, ObservableObject {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "ContentViewModel")

    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol

    init(
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.fileUtil = fileUtil
        self.fileManager = fileManager
    }

    func getSharedFiles(
    ) -> [URL] {
        do {
            ContentViewModel.logger.debug("Checking for shared files...")
            let sharedFolderURL = try Directories.getSharedFolder(fileManager: fileManager).validURL(
                fileUtil: fileUtil,
                fileManager: fileManager
            )

            let contents = try fileManager.contentsOfDirectory(
                at: sharedFolderURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)

            if contents.isEmpty {
                ContentViewModel.logger.debug("Shared files folder is empty")
            } else {
                ContentViewModel.logger.debug("Found \(contents.count) shared files")
            }

            return contents
        } catch {
            ContentViewModel.logger.error("Unable to get shared files: \(error.localizedDescription)")
            return []
        }
    }
}
