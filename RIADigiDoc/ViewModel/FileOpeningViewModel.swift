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
            let validFiles = try await fileOpeningRepository.getValidFiles(
                sharedContainerViewModel.getFileOpeningResult() ?? .failure(FileOpeningError.noDataFiles)
            )
            sharedContainerViewModel.setSignedContainer(
                signedContainer:
                    try await fileOpeningRepository.openOrCreateContainer(urls: validFiles))
            handleLoadingSuccess()

        } catch {
            FileOpeningViewModel.logger.error("\(error.localizedDescription)")
            errorMessage = AlertMessage(message: error.localizedDescription)
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
}
