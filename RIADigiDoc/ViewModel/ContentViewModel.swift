import Foundation
import OSLog
import UtilsLib
import CommonsLib

@MainActor
class ContentViewModel: ContentViewModelProtocol, ObservableObject {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "ContentViewModel")

    func getSharedFiles(
        fileManager: FileManagerProtocol = FileManager.default
    ) -> [URL] {
        do {
            ContentViewModel.logger.debug("Checking for shared files...")
            let sharedFolderURL = try Directories.getSharedFolder(fileManager: fileManager).validURL(
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
