import Foundation
import OSLog
import LibdigidocLibSwift

@MainActor
class FileOpeningViewModel: ObservableObject {
    @Published var isFileOpeningLoading: Bool = false
    @Published var isNavigatingToNextView: Bool = false

    @Published var signedContainer: SignedContainer = SignedContainer()
    @Published var errorMessage: AlertMessage?

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "FileOpeningViewModel")

    private let fileOpeningRepository: FileOpeningRepositoryProtocol
    private let sharedContainerViewModel: SharedContainerViewModel

    init(
        fileOpeningRepository: FileOpeningRepositoryProtocol,
        sharedContainerViewModel: SharedContainerViewModel
    ) {
        self.fileOpeningRepository = fileOpeningRepository
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    func handleFiles() async {
        do {
            FileOpeningViewModel.logger.debug("Handling chosen files from file system")
            let validFiles = try await fileOpeningRepository.getValidFiles(
                sharedContainerViewModel.getFileOpeningResult() ?? .failure(FileOpeningError.noDataFiles)
            )

            FileOpeningViewModel.logger.debug("Found \(validFiles.count) valid file(s)")

            if validFiles.isEmpty {
                FileOpeningViewModel.logger.debug("No valid files found")
                throw FileOpeningError.noDataFiles
            }

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

    func handleError() {
        errorMessage = nil
        isFileOpeningLoading = false
        isNavigatingToNextView = false
    }

    private func handleError(_ error: Error) {
        let ddeMessage = (error as? DigiDocError)?.description ?? error.localizedDescription
        FileOpeningViewModel.logger.error("\(ddeMessage)")

        if let dde = error as? DigiDocError {
            errorMessage = createAlertMessage(for: dde)
        } else {
            errorMessage = AlertMessage(message: error.localizedDescription)
        }
    }

    private func createAlertMessage(for error: DigiDocError) -> AlertMessage {
        switch error {
        case .initializationFailed:
            return AlertMessage(message: NSLocalizedString("General error", comment: ""))
        case .containerCreationFailed(let errorDetail),
            .containerOpeningFailed(let errorDetail),
            .containerSavingFailed(let errorDetail):
            return AlertMessage(
                message: String(
                    format: NSLocalizedString("Failed to open container %@", comment: ""),
                    errorDetail.userInfo["fileName"] ?? "")
            )
        case .addingFilesToContainerFailed(let errorDetail):
            return AlertMessage(
                message: String(
                    format: NSLocalizedString("Failed to open file %@", comment: ""),
                    errorDetail.userInfo["fileName"] ?? "")
            )
        case .alreadyInitialized:
            return AlertMessage(message: NSLocalizedString("Libdigidocpp is already initialized", comment: ""))
        }
    }
}
