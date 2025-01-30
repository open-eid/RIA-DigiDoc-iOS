import Foundation
import OSLog
import LibdigidocLibSwift
import CommonsLib

@MainActor
class SigningViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SigningViewModel")

    @Published var dataFiles: [DataFileWrapper] = []
    @Published var signatures: [SignatureWrapper] = []
    @Published var containerName: String = CommonsLib.Constants.Container.DefaultName
    @Published var containerMimetype: String = "N/A"

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

        SigningViewModel.logger.debug("Container data loaded")
    }

    func loadContainerMimetype() async {
        containerMimetype = await signedContainer.getContainerMimetype()
    }
}
