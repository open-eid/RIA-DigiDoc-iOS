import Foundation
import LibdigidocLibSwift

public enum FileOpeningError: Error {
    case unableToRetrieveFileSize
    case invalidFileSize
    case emptyFile
    case noDataFiles
}

extension FileOpeningError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unableToRetrieveFileSize, .invalidFileSize:
            return NSLocalizedString("Invalid file size", comment: "")
        case .emptyFile, .noDataFiles:
            return NSLocalizedString("General error", comment: "")
        }
    }
}
