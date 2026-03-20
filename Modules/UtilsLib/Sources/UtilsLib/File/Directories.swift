/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import FactoryKit
import CommonsLib

public struct Directories {
    public static func getTempDirectory(
        subfolder: String,
        fileManager: FileManagerProtocol
    ) throws -> URL {
        var tempDirectory = fileManager.temporaryDirectory
            .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)

        tempDirectory = appendSubfolder(baseFolder: tempDirectory, subfolder: subfolder)
        try createDirectoryIfNeeded(at: tempDirectory, fileManager: fileManager)
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

        let sharedContainerSubfolder = sharedContainerURL.appending(path: subfolder)
        try createDirectoryIfNeeded(at: sharedContainerSubfolder, fileManager: fileManager)
        return sharedContainerSubfolder
    }

    public static func getCacheDirectory(
        subfolders: [String] = [],
        fileManager: FileManagerProtocol
    ) throws -> URL {
        var cacheDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
            .appending(path: BundleUtil.getBundleIdentifier(), directoryHint: .isDirectory)

        for subfolder in subfolders {
            cacheDirectory = appendSubfolder(baseFolder: cacheDirectory, subfolder: subfolder)
        }

        try createDirectoryIfNeeded(at: cacheDirectory, fileManager: fileManager)
        return cacheDirectory
    }

    public static func getLibraryDirectory(fileManager: FileManagerProtocol) -> URL? {
        return fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
    }

    public static func getDocumentsDirectory(fileManager: FileManagerProtocol) -> URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    public static func getApplicationDirectory(fileManager: FileManagerProtocol) -> URL? {
        return fileManager.urls(for: .applicationDirectory, in: .userDomainMask).first
    }

    public static func getConfigDirectory(from directory: URL? = nil, fileManager: FileManagerProtocol) throws -> URL {
        let baseDirectory = try directory ?? getCacheDirectory(fileManager: fileManager)
        return appendSubfolder(baseFolder: baseDirectory, subfolder: Constants.Configuration.CacheConfigFolder)
    }

    public static func getTslCacheDirectory(fileManager: FileManagerProtocol) -> URL? {
        return getLibraryDirectory(fileManager: fileManager)
    }

    public static func getLibdigidocLogFile(
        from directory: URL?,
        fileManager: FileManagerProtocol
    ) throws -> URL? {
        let baseDirectory = try directory ?? getCacheDirectory(fileManager: fileManager)
        let logsDirectory = baseDirectory.appending(path: CommonsLib.Constants.Folder.Logs)
        try createDirectoryIfNeeded(at: logsDirectory, fileManager: fileManager)
        return logsDirectory.appending(path: Constants.File.LibDigidocLog)
    }

    private static func appendSubfolder(baseFolder: URL, subfolder: String = "") -> URL {
        if !subfolder.isEmpty {
            return baseFolder.appending(path: subfolder, directoryHint: .isDirectory)
        }
        return baseFolder
    }

    private static func createDirectoryIfNeeded(
        at url: URL,
        fileManager: FileManagerProtocol
    ) throws {
        if !fileManager.fileExists(atPath: url.resolvedPath) {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
}
