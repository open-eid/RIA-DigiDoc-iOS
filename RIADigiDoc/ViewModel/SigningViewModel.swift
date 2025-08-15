import Foundation
import FactoryKit
import OSLog
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@MainActor
class SigningViewModel: SigningViewModelProtocol, ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SigningViewModel")

    @Published var dataFiles: [DataFileWrapper] = []
    @Published var signatures: [SignatureWrapper] = []
    @Published var containerName: String = CommonsLib.Constants.Container.DefaultName
    @Published var containerMimetype: String = "N/A"
    @Published var containerURL: URL?
    @Published var errorMessage: String?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol

    private var loadedSignedContainer: SignedContainerProtocol?

    var signedContainer: SignedContainerProtocol? {
        loadedSignedContainer ?? sharedContainerViewModel.getSignedContainer()
    }

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileUtil = fileUtil
        self.fileManager = fileManager
    }

    func loadContainerData(signedContainer: SignedContainerProtocol?) async {
        SigningViewModel.logger.debug("Loading container data")
        guard let signedContainer else {
            SigningViewModel.logger.error("Cannot load container data. Signed container is nil.")
            return
        }

        self.loadedSignedContainer = signedContainer

        self.containerName = await signedContainer.getContainerName()
        self.dataFiles = await signedContainer.getDataFiles()
        self.signatures = await signedContainer.getSignatures()
        self.containerMimetype = await signedContainer.getContainerMimetype()
        self.containerURL = await signedContainer.getRawContainerFile()

        SigningViewModel.logger.debug("Container data loaded")
    }

    func isSigned() -> Bool {
        return !signatures.isEmpty
    }

    func createCopyOfContainerForSaving(containerURL: URL?) -> URL? {
        guard let containerLocation = containerURL else {
            SigningViewModel.logger.error("Unable to get container to create copy for saving")
            return nil
        }

        do {
            let savedFilesDirectory = try Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles,
                fileManager: fileManager
            )

            let filename = containerLocation.lastPathComponent.sanitized().isEmpty
                ? CommonsLib.Constants.Container.DefaultName
                : containerLocation.lastPathComponent.sanitized()

            let tempSavedFileLocation = savedFilesDirectory.appendingPathComponent(filename)

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

    func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        do {
            let directory = try savedFilesDirectory ?? Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles,
                fileManager: fileManager
            )
            try fileManager.removeItem(at: directory)
            SigningViewModel.logger.debug("Saved Files directory removed")
        } catch {
            SigningViewModel.logger.error("Unable to delete saved files directory: \(error.localizedDescription)")
        }
    }

    @discardableResult
    public func renameContainer(to newName: String) async -> URL? {
        do {
            return try await signedContainer?.renameContainer(to: newName)
        } catch {
            SigningViewModel.logger.error("Unable to rename container: \(error)")
            if let digiDocError = error as? DigiDocError {
                switch digiDocError {
                case .containerRenamingFailed(let errorDetail),
                        .containerSavingFailed(let errorDetail):
                    errorMessage = String(
                        format: NSLocalizedString("Failed to rename file %@", comment: ""),
                        errorDetail.userInfo["fileName"] ?? ""
                    )
                default:
                    errorMessage = "General error"
                }
            } else {
                errorMessage = "General error"
            }
            return nil
        }
    }

    func getDataFileURL(_ dataFile: DataFileWrapper) async -> Result<URL, Error> {
        do {
            let dataFileURL = try await signedContainer?.saveDataFile(dataFile: dataFile)

            guard fileUtil.fileExists(fileLocation: dataFileURL), let fileURL = dataFileURL else {
                throw DigiDocError.containerDataFileSavingFailed(
                    ErrorDetail(
                        message: "Unable to save datafile",
                        code: 0,
                        userInfo: ["fileName": dataFileURL?.lastPathComponent ?? ""]
                    )
                )
            }

            return .success(fileURL)
        } catch {
            return .failure(error)
        }
    }
}
