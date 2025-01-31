import Foundation
import CommonsLib

public struct Directories {
    public static func getTempDirectory(subfolder: String) throws -> URL {
        var tempDirectory: URL
        if #available(iOS 16.0, *) {
            tempDirectory = FileManager.default.temporaryDirectory
                .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
            if !subfolder.isEmpty {
                tempDirectory = tempDirectory.appending(path: subfolder, directoryHint: .isDirectory)
            }
        } else {
            tempDirectory = FileManager.default.temporaryDirectory
                .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
            if !subfolder.isEmpty {
                tempDirectory = tempDirectory.appendingPathComponent(subfolder, isDirectory: true)
            }
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

    public static func getCacheDirectory(subfolder: String = "") throws -> URL {
        var cacheDirectory: URL
        if #available(iOS 16.0, *) {
            cacheDirectory = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
            if !subfolder.isEmpty {
                cacheDirectory = cacheDirectory.appending(path: subfolder, directoryHint: .isDirectory)
            }
        } else {
            cacheDirectory = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
            if !subfolder.isEmpty {
                cacheDirectory = cacheDirectory.appendingPathComponent(subfolder, isDirectory: true)
            }
        }

        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default
                .createDirectory(
                    at: cacheDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
        }

        return cacheDirectory
    }
}
