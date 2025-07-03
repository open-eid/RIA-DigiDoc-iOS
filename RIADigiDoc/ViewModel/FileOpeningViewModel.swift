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

    @Published var signedContainer: SignedContainer = SignedContainer()
    @Published var errorMessage: ToastMessage?

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "FileOpeningViewModel")

    private let fileOpeningRepository: FileOpeningRepositoryProtocol
    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol

    init(
        fileOpeningRepository: FileOpeningRepositoryProtocol,
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.fileOpeningRepository = fileOpeningRepository
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileUtil = fileUtil
        self.fileManager = fileManager
    }

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

            sharedContainerViewModel.setAddedFilesCount(addedFiles: validFiles.count)

            sharedContainerViewModel.setSignedContainer(
                signedContainer:
                    try await fileOpeningRepository.openOrCreateContainer(urls: validFiles))
            FileOpeningViewModel.logger.debug("Signed container set successfully")
            handleLoadingSuccess()

        } catch {
            handleError(error)
        }
    }

    func handleLoadingSuccess() {
        isFileOpeningLoading = false
        isNavigatingToNextView = true
    }

    func showFileAddedMessage() async -> Bool {
        return await sharedContainerViewModel.getSignedContainer()?.getSignatures().isEmpty ?? true
    }

    func addedFilesCount() -> Int {
        return sharedContainerViewModel.getAddedFilesCount()
    }

    func handleError() {
        errorMessage = nil
        isFileOpeningLoading = false
        isNavigatingToNextView = false
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
        case .initializationFailed:
            return ToastMessage(message: NSLocalizedString("General error", comment: ""))
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
        case .alreadyInitialized:
            return ToastMessage(message: NSLocalizedString("Libdigidocpp is already initialized", comment: ""))
        }
    }
}
