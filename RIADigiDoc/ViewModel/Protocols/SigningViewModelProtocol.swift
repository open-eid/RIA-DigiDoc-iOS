import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SigningViewModelProtocol: Sendable {
    func loadContainerData(signedContainer: SignedContainer?) async
    func createCopyOfContainerForSaving(containerURL: URL?) -> URL?
    func checkIfContainerFileExists(fileLocation: URL?) -> Bool
    func removeSavedFilesDirectory(savedFilesDirectory: URL?)
}
