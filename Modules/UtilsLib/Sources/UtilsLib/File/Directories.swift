import Foundation
import FactoryKit
import CommonsLib

public struct Directories {
    public static func getTempDirectory(
        subfolder: String,
        fileManager: FileManagerProtocol
    ) throws -> URL {
        var tempDirectory: URL
        if #available(iOS 16.0, *) {
            tempDirectory = fileManager.temporaryDirectory
                .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
            if !subfolder.isEmpty {
                tempDirectory = tempDirectory.appending(path: subfolder, directoryHint: .isDirectory)
            }
        } else {
            tempDirectory = fileManager.temporaryDirectory
                .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
            if !subfolder.isEmpty {
                tempDirectory = tempDirectory.appendingPathComponent(subfolder, isDirectory: true)
            }
        }

        if !fileManager.fileExists(atPath: tempDirectory.path) {
            try fileManager
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
        subfolder: String = "Temp",
        fileManager: FileManagerProtocol
    ) throws -> URL {
        guard let sharedContainerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            throw URLError(.fileDoesNotExist)
        }

        let sharedContainerSubfolder = sharedContainerURL.appendingPathComponent(subfolder)

        if !fileManager.fileExists(atPath: sharedContainerSubfolder.path) {
            try fileManager
                .createDirectory(
                    at: sharedContainerSubfolder,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
        }

        return sharedContainerSubfolder
    }

    public static func getCacheDirectory(
        subfolder: String = "",
        fileManager: FileManagerProtocol
    ) throws -> URL {
        var cacheDirectory: URL
        if #available(iOS 16.0, *) {
            cacheDirectory = try fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
                .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)
            if !subfolder.isEmpty {
                cacheDirectory = cacheDirectory.appending(path: subfolder, directoryHint: .isDirectory)
            }
        } else {
            cacheDirectory = try fileManager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
                .appendingPathComponent(BundleUtil.getBundleIdentifier(), isDirectory: true)
            if !subfolder.isEmpty {
                cacheDirectory = cacheDirectory.appendingPathComponent(subfolder, isDirectory: true)
            }
        }

        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager
                .createDirectory(
                    at: cacheDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
        }

        return cacheDirectory
    }

    public static func getLibraryDirectory(
        fileManager: FileManagerProtocol
    ) -> URL? {
        if let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
            return libraryDirectory
        }
        return nil
    }

    public static func getConfigDirectory(from directory: URL? = nil, fileManager: FileManagerProtocol) throws -> URL {
        let baseDirectory = try directory ?? getCacheDirectory(fileManager: fileManager)
        return baseDirectory.appendingPathComponent(
            Constants.Configuration.CacheConfigFolder,
            conformingTo: .folder
        )
    }

    public static func getTslCacheDirectory(fileManager: FileManagerProtocol) -> URL? {
        return getLibraryDirectory(fileManager: fileManager)
    }

    public static func getLibdigidocLogFile(
        from directory: URL?,
        fileManager: FileManagerProtocol
    ) throws -> URL? {
        let libdigidocppLogFile = "libdigidocpp.log"

        if let mainDirectory = directory {
            let primaryLogsDirectory = mainDirectory.appendingPathComponent("logs")

            if !fileManager.fileExists(atPath: primaryLogsDirectory.path) {
                try fileManager.createDirectory(
                    at: primaryLogsDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                return primaryLogsDirectory.appendingPathComponent(libdigidocppLogFile)
            } else {
                return primaryLogsDirectory.appendingPathComponent(libdigidocppLogFile)
            }
        }

        let cacheDirectory = try getCacheDirectory(fileManager: fileManager)
        let fallbackLogsDirectory = cacheDirectory.appendingPathComponent("logs")

        if !fileManager.fileExists(atPath: fallbackLogsDirectory.path) {
            try fileManager.createDirectory(
                at: fallbackLogsDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        return fallbackLogsDirectory.appendingPathComponent(libdigidocppLogFile)
    }

}
