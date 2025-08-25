import Foundation
import LibdigidocLibSwift

@MainActor
class SharedContainerViewModel: SharedContainerViewModelProtocol, ObservableObject {
    private var signedContainer: SignedContainerProtocol?
    private var fileOpeningResult: Result<[URL], Error>?
    private var addedFilesCount: Int = 0
    private var nestedContainers: [SignedContainerProtocol] = []

    func setSignedContainer(_ signedContainer: SignedContainerProtocol?) {
        self.signedContainer = signedContainer
        addNestedContainer(signedContainer)
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

    private func addNestedContainer(_ container: SignedContainerProtocol?) {
        guard let container else { return }
        if !nestedContainers.contains(where: { $0 === container }) {
            nestedContainers.append(container)
        }
    }

    @discardableResult
    func removeLastContainer() -> SignedContainerProtocol? {
        nestedContainers.popLast()
    }

    func clearContainers() {
        nestedContainers.removeAll()
    }

    func currentContainer() -> SignedContainerProtocol? {
        nestedContainers.last
    }

    func isNestedContainer(_ container: SignedContainerProtocol?) -> Bool {
        guard let container else { return false }
        return nestedContainers.count > 1 && currentContainer().map { $0 === container } == true
    }

    func containers() -> [SignedContainerProtocol] {
        return nestedContainers
    }
}
