import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SharedContainerViewModelProtocol: Sendable {
    func setSignedContainer(signedContainer: SignedContainerProtocol?)
    func getSignedContainer() -> SignedContainerProtocol?
    func setFileOpeningResult(fileOpeningResult: Result<[URL], Error>?)
    func getFileOpeningResult() -> Result<[URL], Error>?
    func setAddedFilesCount(addedFiles: Int)
    func getAddedFilesCount() -> Int
}
