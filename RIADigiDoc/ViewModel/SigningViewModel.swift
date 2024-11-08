import Foundation
import OSLog
import LibdigidoclibSwift

@MainActor
class SigningViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SigningViewModel")

    @Published var dataFiles: [DataFileWrapper] = []
    @Published var signatures: [SignatureWrapper] = []

    let sharedContainerViewModel: SharedContainerViewModel

    init(
        sharedContainerViewModel: SharedContainerViewModel
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
    }

    func loadDataFiles(signedContainer: SignedContainer?) {
        guard let signedContainer else {
            return
        }
        Task {
            self.dataFiles = await signedContainer.getDataFiles()
            self.signatures = await signedContainer.getSignatures()
        }
    }
}
