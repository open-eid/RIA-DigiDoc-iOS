import Foundation
import CommonsLib

struct Directories {
    static func getTempDirectoryURL(subfolder: String) throws -> URL {
        var tempDirectory: URL
        if #available(iOS 16.0, *) {
            tempDirectory = FileManager.default.temporaryDirectory
                .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
                .appending(path: subfolder, directoryHint: .isDirectory)
        } else {
            tempDirectory = FileManager.default.temporaryDirectory
                .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
                .appendingPathComponent(subfolder, isDirectory: true)
        }

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
