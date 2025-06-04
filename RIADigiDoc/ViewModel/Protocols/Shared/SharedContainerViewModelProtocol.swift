import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SharedContainerViewModelProtocol: Sendable {
    func setSignedContainer(signedContainer: SignedContainer?)
    func getSignedContainer() -> SignedContainer?
    func setFileOpeningResult(fileOpeningResult: Result<[URL], Error>?)
    func getFileOpeningResult() -> Result<[URL], Error>?
}
