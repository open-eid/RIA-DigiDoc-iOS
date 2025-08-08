import Foundation
import OSLog
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@MainActor
class DataFilesViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "DataFilesViewModel")

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileManager: FileManagerProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileManager: FileManagerProtocol,
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileManager = fileManager
    }

    func saveDataFile(dataFile: DataFileWrapper) async -> URL? {
        do {
            return try await sharedContainerViewModel.getSignedContainer()?.getDataFile(dataFile: dataFile)
        } catch {
            DataFilesViewModel.logger.error(
                "Unable to save datafile \(dataFile.fileName): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func checkIfContainerFileExists(fileLocation: URL?) -> Bool {
        guard let file = fileLocation else { return false }
        return fileManager.fileExists(atPath: file.path)
    }

    func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        do {
            let directory = try savedFilesDirectory ?? Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles,
                fileManager: fileManager
            )
            try fileManager.removeItem(at: directory)
            DataFilesViewModel.logger.debug("Saved Files directory removed")
        } catch {
            DataFilesViewModel.logger.error("Unable to delete saved files directory: \(error.localizedDescription)")
        }
    }
}
