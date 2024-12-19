import Foundation

enum FileImportError: Error, Equatable {
    case loadError(description: String)
    case dataConversionFailed
    case invalidItemData
}
