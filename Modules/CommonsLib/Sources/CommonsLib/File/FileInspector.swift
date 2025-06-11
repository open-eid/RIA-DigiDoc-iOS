import Foundation

public struct FileInspector: FileInspectorProtocol {

    public init() {}

    public func fileSize(for url: URL) throws -> Int {
        let resources = try url.resourceValues(forKeys: [.fileSizeKey])

        guard let fileSize = resources.fileSize, fileSize > 0 else {
            throw FileOpeningError.invalidFileSize
        }

        return fileSize
    }
}
