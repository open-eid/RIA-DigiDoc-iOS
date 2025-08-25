import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SharedContainerViewModelProtocol: Sendable {
    func setSignedContainer(_ signedContainer: SignedContainerProtocol?)
    func setFileOpeningResult(fileOpeningResult: Result<[URL], Error>?)
    func getFileOpeningResult() -> Result<[URL], Error>?
    func setAddedFilesCount(addedFiles: Int)
    func getAddedFilesCount() -> Int

    func currentContainer() -> SignedContainerProtocol?
    func isNestedContainer(_ container: SignedContainerProtocol?) -> Bool
    func containers() -> [SignedContainerProtocol]
    @discardableResult func removeLastContainer() -> SignedContainerProtocol?
    func clearContainers()
}
