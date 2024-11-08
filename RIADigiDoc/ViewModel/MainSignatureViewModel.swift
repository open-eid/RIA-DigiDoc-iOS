import Foundation
import OSLog
import LibdigidoclibSwift

@MainActor
class MainSignatureViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "MainSignatureViewModel")

    @Published var isImporting = false
    @Published var signedContainer: SignedContainer = SignedContainer()

    private let sharedContainerViewModel: SharedContainerViewModel

    init(
        sharedContainerViewModel: SharedContainerViewModel
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool {
        if !isImportingValue && !isFileOpeningLoading {
            MainSignatureViewModel.logger.info("User cancelled the file chooser")
            return true
        }

        return false
    }

    func setChosenFiles(_ chosenFiles: Result<[URL], Error>) {
        sharedContainerViewModel.setFileOpeningResult(fileOpeningResult: chosenFiles)
    }
}
