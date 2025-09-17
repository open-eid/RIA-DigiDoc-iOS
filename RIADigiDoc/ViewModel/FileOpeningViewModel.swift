import Foundation
import OSLog
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@MainActor
class FileOpeningViewModel: FileOpeningViewModelProtocol, ObservableObject {
    @Published var isFileOpeningLoading: Bool = false
    @Published var isNavigatingToNextView: Bool = false
    @Published var isSivaConfirmed = false

    @Published var signedContainer: SignedContainerProtocol = SignedContainer(
        fileManager: Container.shared.fileManager(),
        containerUtil: Container.shared.containerUtil()
    )
    @Published var errorMessage: ToastMessage?

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "FileOpeningViewModel")

    private let fileOpeningRepository: FileOpeningRepositoryProtocol
    private let sivaRepository: SivaRepositoryProtocol
    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol

    init(
        fileOpeningRepository: FileOpeningRepositoryProtocol,
        sivaRepository: SivaRepositoryProtocol,
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.fileOpeningRepository = fileOpeningRepository
        self.sivaRepository = sivaRepository
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileUtil = fileUtil
        self.fileManager = fileManager
    }

    private var files: [URL] = []

    func handleFiles() async {
        do {
            FileOpeningViewModel.logger.debug("Handling chosen files from file system or from external sources")
            let validFiles = try await fileOpeningRepository.getValidFiles(
                sharedContainerViewModel.getFileOpeningResult() ?? .failure(FileOpeningError.noDataFiles)
            )

            try fileUtil.removeSharedFiles(url: Directories.getSharedFolder(fileManager: fileManager))

            FileOpeningViewModel.logger.debug("Found \(validFiles.count) valid file(s)")

            if validFiles.isEmpty {
                FileOpeningViewModel.logger.debug("No valid files found")
                throw FileOpeningError.noDataFiles
            }

            files = validFiles
        } catch {
            handleError(error)
        }
    }

    func handleSivaConfirmation() async {
        sharedContainerViewModel.setIsSivaConfirmed(true)
        sharedContainerViewModel.setAddedFilesCount(addedFiles: files.count)

        do {
            let container = try await fileOpeningRepository.openOrCreateContainer(urls: files, isSivaConfirmed: true)
            if await container.getContainerMimetype() == Constants.MimeType.Asics {
                try await handleAsicsSivaConfirmation()
            } else {
                sharedContainerViewModel.setSignedContainer(container)
            }

            handleLoadingSuccess(isSivaConfirmed: true)
        } catch {
            handleError()
        }
    }

    func handleSivaCancellation() async {
        sharedContainerViewModel.setIsSivaConfirmed(false)
        sharedContainerViewModel.setAddedFilesCount(addedFiles: files.count)

        let fileMimetype = await files.first?.mimeType()

        if fileMimetype != nil {
            if fileMimetype == Constants.MimeType.Ddoc {
                handleError()
            } else if fileMimetype == Constants.MimeType.Asics {
                do {
                    let container = try await fileOpeningRepository
                        .openOrCreateContainer(urls: files, isSivaConfirmed: false)
                    sharedContainerViewModel.setSignedContainer(container)
                    FileOpeningViewModel.logger.debug("Asics signed container set successfully")
                    handleLoadingSuccess(isSivaConfirmed: false)
                } catch {
                    handleError()
                }
            } else {
                handleError()
            }
        }
    }

    private func handleAsicsSivaConfirmation() async throws {
        let parentContainer = try await fileOpeningRepository.openOrCreateContainer(urls: files, isSivaConfirmed: true)
        if await sivaRepository.isTimestampedContainer(signedContainer: parentContainer) {
            let nestedTimestampedContainer = try await sivaRepository
                .getTimestampedContainer(parentContainer: parentContainer)
            sharedContainerViewModel.setSignedContainer(nestedTimestampedContainer)
        } else {
            sharedContainerViewModel.setSignedContainer(parentContainer)
        }
    }

    func handleLoadingSuccess(isSivaConfirmed: Bool) {
        self.isSivaConfirmed = isSivaConfirmed
        isFileOpeningLoading = false
        isNavigatingToNextView = true
    }

    func showFileAddedMessage() async -> Bool {
        return await sharedContainerViewModel.currentContainer()?.getSignatures().isEmpty ?? true
    }

    func addedFilesCount() -> Int {
        return sharedContainerViewModel.getAddedFilesCount()
    }

    func handleError() {
        errorMessage = nil
        isFileOpeningLoading = false
        isNavigatingToNextView = false
    }

    func isSivaConfirmationNeeded() async -> Bool {
        do {
            return try await fileOpeningRepository.isSivaConfirmationNeeded(files: files)
        } catch {
            FileOpeningViewModel.logger
                .error("Unable to check if SiVa confirmation is needed. \(error)")
            handleError(error)
            return false
        }
    }

    private func handleError(_ error: Error) {
        let ddeMessage = (error as? DigiDocError)?.description ?? error.localizedDescription
        FileOpeningViewModel.logger.error("\(ddeMessage)")

        if let dde = error as? DigiDocError {
            errorMessage = createToastMessage(for: dde)
        } else {
            errorMessage = ToastMessage(message: error.localizedDescription)
        }
    }

    private func createToastMessage(for error: DigiDocError) -> ToastMessage {
        switch error {
        case .containerCreationFailed(let errorDetail),
                .containerOpeningFailed(let errorDetail),
                .containerSavingFailed(let errorDetail):
            return ToastMessage(
                message: String(
                    format: NSLocalizedString("Failed to open container %@", comment: ""),
                    errorDetail.userInfo["fileName"] ?? "")
            )
        case .addingFilesToContainerFailed(let errorDetail):
            return ToastMessage(
                message: String(
                    format: NSLocalizedString("Failed to open file %@", comment: ""),
                    errorDetail.userInfo["fileName"] ?? "")
            )
        case .containerDataFileSavingFailed(let errorDetail):
            return ToastMessage(
                message: String(
                    format: NSLocalizedString("Failed to save file %@", comment: ""),
                    errorDetail.userInfo["fileName"] ?? "")
            )
        case .alreadyInitialized:
            return ToastMessage(message: NSLocalizedString("Libdigidocpp is already initialized", comment: ""))
        default:
            return ToastMessage(message: NSLocalizedString("General error", comment: ""))
        }
    }
}
