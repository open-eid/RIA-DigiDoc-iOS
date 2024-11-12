import Foundation

struct Directories {
    static func getTempDirectoryURL(subfolder: String) throws -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(subfolder, isDirectory: true)

        if !FileManager.default.fileExists(atPath: tempDirectory.path) {
            try FileManager.default
                .createDirectory(
                    at: tempDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
        }

        return tempDirectory
    }
}
