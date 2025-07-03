import Foundation
import CommonsLib
import UtilsLib

/// @mockable
@MainActor
public protocol ContentViewModelProtocol: Sendable {
    func getSharedFiles() -> [URL]
}
