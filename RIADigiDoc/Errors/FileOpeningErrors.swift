import Foundation

public enum FileOpeningError: Error {
    case unableToRetrieveFileSize(String)
    case invalidFileSize
    case emptyFile
    case noDataFiles
}
