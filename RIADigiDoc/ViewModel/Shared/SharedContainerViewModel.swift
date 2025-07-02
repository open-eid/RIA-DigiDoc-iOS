import Foundation
import LibdigidocLibSwift

class SharedContainerViewModel: SharedContainerViewModelProtocol, ObservableObject {
    private var signedContainer: SignedContainer?
    private var fileOpeningResult: Result<[URL], Error>?
    private var addedFilesCount: Int = 0

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

    func setAddedFilesCount(addedFiles: Int) {
        self.addedFilesCount = addedFiles
    }

    func getAddedFilesCount() -> Int {
        return addedFilesCount
    }
}
