import Foundation
import LibdigidoclibSwift

class SharedContainerViewModel: ObservableObject {
    private var signedContainer: SignedContainer?
    private var fileOpeningResult: Result<[URL], Error>?

    func setSignedContainer(signedContainer: SignedContainer?) {
        self.signedContainer = signedContainer
    }

    func getSignedContainer() -> SignedContainer? {
        return signedContainer
    }

    func setFileOpeningResult(fileOpeningResult: Result<[URL], Error>?) {
        self.fileOpeningResult = fileOpeningResult
    }

    func getFileOpeningResult() -> Result<[URL], Error>? {
        return fileOpeningResult
    }
}
