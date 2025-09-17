import Foundation

/// @mockable
@MainActor
public protocol FileOpeningViewModelProtocol: Sendable {
    func handleFiles() async
    func handleLoadingSuccess(isSivaConfirmed: Bool) async
    func handleError() async
}
