import Foundation

enum FileImportError: Error {
    case loadError(description: String)
    case dataConversionFailed
    case invalidItemData
}
