import Foundation
import CommonsLib

/// @mockable
@MainActor
public protocol ContentViewModelProtocol: Sendable {
    func getSharedFiles(fileManager: FileManagerProtocol) -> [URL]
}
