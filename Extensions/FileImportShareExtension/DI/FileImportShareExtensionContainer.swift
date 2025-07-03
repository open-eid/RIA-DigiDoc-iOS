import FactoryKit

extension Container {

    @MainActor
    var shareViewModel: Factory<ShareViewModel> {
        self {
            @MainActor in ShareViewModel(
                fileManager: self.fileManager(),
                resourceChecker: self.urlResourceChecker()
            )
        }
    }
}
