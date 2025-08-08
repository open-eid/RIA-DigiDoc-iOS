import Foundation

/// @mockable
@MainActor
public protocol HomeViewModelProtocol: Sendable {
    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool
    func setChosenFiles(_ chosenFiles: Result<[URL], Error>)
}
