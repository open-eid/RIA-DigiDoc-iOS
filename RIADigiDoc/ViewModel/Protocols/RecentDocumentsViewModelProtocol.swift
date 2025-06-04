import Foundation
import LibdigidocLibSwift
import CommonsLib

/// @mockable
@MainActor
public protocol RecentDocumentsViewModelProtocol: Sendable {
    func setChosenFiles(_ chosenFiles: Result<[URL], Error>)
    func loadFiles()
    func deleteFile(at offsets: IndexSet)
}
