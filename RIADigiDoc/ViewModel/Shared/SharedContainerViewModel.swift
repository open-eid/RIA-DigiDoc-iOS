import Foundation
import LibdigidocLibSwift

class SharedContainerViewModel: SharedContainerViewModelProtocol, ObservableObject {
    private var signedContainer: SignedContainerProtocol?
    private var fileOpeningResult: Result<[URL], Error>?
    private var addedFilesCount: Int = 0

    func setSignedContainer(signedContainer: SignedContainerProtocol?) {
        self.signedContainer = signedContainer
    }

    func getSignedContainer() -> SignedContainerProtocol? {
        return signedContainer
    }

    func setFileOpeningResult(fileOpeningResult: Result<[URL], Error>?) {
        self.fileOpeningResult = fileOpeningResult
    }

    func getFileOpeningResult() -> Result<[URL], Error>? {
        return fileOpeningResult
    }

    func setAddedFilesCount(addedFiles: Int) {
        self.addedFilesCount = addedFiles
    }

    func getAddedFilesCount() -> Int {
        return addedFilesCount
    }
}
