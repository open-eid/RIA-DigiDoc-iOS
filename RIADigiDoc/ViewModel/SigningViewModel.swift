import Foundation
import OSLog
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@MainActor
class SigningViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SigningViewModel")

    @Published var dataFiles: [DataFileWrapper] = []
    @Published var signatures: [SignatureWrapper] = []
    @Published var containerName: String = CommonsLib.Constants.Container.DefaultName
    @Published var containerMimetype: String = "N/A"
    @Published var containerURL: URL?

    let sharedContainerViewModel: SharedContainerViewModel

    var signedContainer: SignedContainer = SignedContainer()

    init(
        sharedContainerViewModel: SharedContainerViewModel
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    func loadContainerData(signedContainer: SignedContainer?) async {
        SigningViewModel.logger.debug("Loading container data")
        guard let signedContainer else {
            SigningViewModel.logger.error("Cannot load container data. Signed container is nil.")
            return
        }

        self.signedContainer = signedContainer

        self.containerName = await signedContainer.getContainerName()
        self.dataFiles = await signedContainer.getDataFiles()
        self.signatures = await signedContainer.getSignatures()
        self.containerMimetype = await signedContainer.getContainerMimetype()
        self.containerURL = await signedContainer.getRawContainerFile()

        SigningViewModel.logger.debug("Container data loaded")
    }

    func createCopyOfContainerForSaving(containerURL: URL?) -> URL? {
        guard let containerLocation = containerURL else {
            SigningViewModel.logger.error("Unable to get container to create copy for saving")
            return nil
        }

        do {
            let savedFilesDirectory = try Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles
            )

            let filename = containerLocation.lastPathComponent.sanitized().isEmpty
            ? CommonsLib.Constants.Container.DefaultName
            : containerLocation.lastPathComponent.sanitized()

            let tempSavedFileLocation = savedFilesDirectory.appendingPathComponent(filename)

            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: tempSavedFileLocation.path) {
                do {
                    try fileManager.removeItem(at: tempSavedFileLocation)
                } catch {
                    SigningViewModel.logger.error("Unable to remove existing file: \(error.localizedDescription)")
                    return nil
                }
            }

            do {
                try fileManager.copyItem(at: containerLocation, to: tempSavedFileLocation)
            } catch {
                SigningViewModel.logger.error("Unable to copy file: \(error.localizedDescription)")
                return nil
            }

            return tempSavedFileLocation
        } catch {
            SigningViewModel.logger.error("Unable to get cache directory: \(error.localizedDescription)")
            return nil
        }
    }

    func checkIfContainerFileExists(fileLocation: URL?) -> Bool {
        guard let file = fileLocation else { return false }
        let fileManager = FileManager.default

        return fileManager.fileExists(atPath: file.path)
    }

    func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        let fileManager = FileManager.default

        do {
            let directory = try savedFilesDirectory ?? Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles
            )
            try fileManager.removeItem(at: directory)
            SigningViewModel.logger.debug("Saved Files directory removed")
        } catch {
            SigningViewModel.logger.error("Unable to delete saved files directory: \(error.localizedDescription)")
        }
    }
}
