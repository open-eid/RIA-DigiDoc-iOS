import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SigningViewModelProtocol: Sendable {
    func loadContainerData(signedContainer: SignedContainerProtocol?) async
    func createCopyOfContainerForSaving(containerURL: URL?) -> URL?
    func checkIfContainerFileExists(fileLocation: URL?) -> Bool
    func removeSavedFilesDirectory(savedFilesDirectory: URL?)
    @discardableResult func renameContainer(to newName: String) async -> URL?
}
