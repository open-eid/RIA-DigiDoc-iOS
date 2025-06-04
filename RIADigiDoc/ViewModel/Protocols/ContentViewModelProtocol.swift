import Foundation

/// @mockable
@MainActor
public protocol ContentViewModelProtocol: Sendable {
    func getSharedFiles() -> [URL]
}
