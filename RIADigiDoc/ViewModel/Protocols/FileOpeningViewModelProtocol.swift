import Foundation

/// @mockable
@MainActor
public protocol FileOpeningViewModelProtocol: Sendable {
    func handleFiles() async
    func showFileAddedMessage() async -> Bool
    func addedFilesCount() -> Int
    func handleError() async
    func isSivaConfirmationNeeded() async -> Bool
}
