import Foundation
import FactoryKit
import OSLog
import LibdigidocLibSwift

@MainActor
class HomeViewModel: HomeViewModelProtocol, ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "HomeViewModel")

    @Published var isImporting = false
    @Published var signedContainer: SignedContainerProtocol = SignedContainer(
        fileManager: Container.shared.fileManager(),
        containerUtil: Container.shared.containerUtil()
    )

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool {
        if !isImportingValue && !isFileOpeningLoading {
            HomeViewModel.logger.info("User cancelled the file chooser")
            return true
        }

        return false
    }

    func setChosenFiles(_ chosenFiles: Result<[URL], Error>) {
        sharedContainerViewModel.setFileOpeningResult(fileOpeningResult: chosenFiles)
    }
}
