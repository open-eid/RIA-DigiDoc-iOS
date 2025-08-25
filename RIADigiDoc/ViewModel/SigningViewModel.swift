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
    @Published var previewFile: URL?
    @Published var selectedDataFile: URL?
    @Published var isShowingFileSaver = false
    @Published private(set) var errorMessage: (String, [String])?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileOpeningService: FileOpeningServiceProtocol
    private let mimeTypeCache: MimeTypeCacheProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol

    @Published private(set) var signedContainer: SignedContainerProtocol?

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileOpeningService: FileOpeningServiceProtocol,
        mimeTypeCache: MimeTypeCacheProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileOpeningService = fileOpeningService
        self.mimeTypeCache = mimeTypeCache
        self.fileUtil = fileUtil
        self.fileManager = fileManager
    }

    func loadContainerData(signedContainer: SignedContainerProtocol?) async {
        SigningViewModel.logger.debug("Loading container data")
        let openedContainer = signedContainer ?? sharedContainerViewModel.currentContainer()
        guard let openedContainer else {
            SigningViewModel.logger.error("Cannot load container data. Signed container is nil.")
            return
        }

        self.signedContainer = openedContainer

        self.containerName = await openedContainer.getContainerName()
        self.dataFiles = await openedContainer.getDataFiles()
        self.signatures = await openedContainer.getSignatures()
        self.containerMimetype = await openedContainer.getContainerMimetype()
        self.containerURL = await openedContainer.getRawContainerFile()

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
                    errorMessage = ("Failed to rename file %@", [errorDetail.userInfo["fileName"] ?? ""])
                default:
                    errorMessage = ("General error", [])
                }
            } else {
                errorMessage = ("General error", [])
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

    func handleFileOpening(dataFile: DataFileWrapper) async {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            let mimeType = await mimeTypeCache.getMimeType(fileUrl: fileURL)

            if Constants.MimeType.SignatureContainers.contains(mimeType) {
                do {
                    try await openNestedContainer(fileURL: fileURL)
                } catch {
                    SigningViewModel.logger.error("Failed to open nested container: \(error)")
                    errorMessage = ("Failed to open file %@", [fileURL.lastPathComponent])
                }
            } else {
                previewFile = fileURL
            }
        case .failure:
            errorMessage = ("Failed to open file %@", [previewFile?.lastPathComponent ?? ""])
        }
    }

    func handleSaveFile(dataFile: DataFileWrapper) async {
        let result = await getDataFileURL(dataFile)

        switch result {
        case .success(let fileURL):
            selectedDataFile = fileURL
            isShowingFileSaver = true

        case .failure:
            errorMessage = ("Failed to save file %@", [dataFile.fileName])
            isShowingFileSaver = false
        }
    }

    func isNestedContainer() -> Bool {
        return sharedContainerViewModel.isNestedContainer(
            sharedContainerViewModel.currentContainer()
        )
    }

    func handleBackButton() async -> Bool {
        if sharedContainerViewModel.containers().count > 1 {
            sharedContainerViewModel.removeLastContainer()
            let currentContainer = sharedContainerViewModel.currentContainer()
            sharedContainerViewModel.setSignedContainer(currentContainer)
            await loadContainerData(signedContainer: currentContainer)
            return false
        } else {
            sharedContainerViewModel.clearContainers()
            return true
        }
    }

    private func openNestedContainer(fileURL: URL) async throws {
        let container = try await fileOpeningService.openOrCreateContainer(dataFiles: [fileURL])
        sharedContainerViewModel.setSignedContainer(container)
        await loadContainerData(signedContainer: container)
    }
}
