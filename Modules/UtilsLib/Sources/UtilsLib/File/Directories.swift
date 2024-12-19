import Foundation
import CommonsLib

public struct Directories {
    public static func getTempDirectory(subfolder: String) throws -> URL {
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

    public static func getSharedFolder(
        appGroupIdentifier: String = Constants.Identifier.Group,
        subfolder: String = "Temp"
    ) throws -> URL {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            throw URLError(.fileDoesNotExist)
        }

        let sharedContainerSubfolder = sharedContainerURL.appendingPathComponent(subfolder)

        if !FileManager.default.fileExists(atPath: sharedContainerSubfolder.path) {
            try FileManager.default
                .createDirectory(
                    at: sharedContainerSubfolder,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
        }

        return sharedContainerSubfolder
    }
}
