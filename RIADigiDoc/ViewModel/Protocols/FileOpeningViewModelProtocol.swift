import Foundation

/// @mockable
public protocol FileOpeningViewModelProtocol: Sendable {
    func handleFiles() async
    func handleLoadingSuccess() async
    func handleError() async
}
