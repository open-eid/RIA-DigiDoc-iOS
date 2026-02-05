/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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
        if !subfolder.isEmpty {
            tempDirectory = tempDirectory.appending(path: subfolder, directoryHint: .isDirectory)
        }

        if !fileManager.fileExists(atPath: tempDirectory.resolvedPath) {
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

        let sharedContainerSubfolder = sharedContainerURL.appending(path: subfolder)

        if !fileManager.fileExists(atPath: sharedContainerSubfolder.resolvedPath) {
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
            cacheDirectory = cacheDirectory.appending(path: subfolder, directoryHint: .isDirectory)
        }

        if !fileManager.fileExists(atPath: cacheDirectory.resolvedPath) {
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

    public static func getDocumentsDirectory(
        fileManager: FileManagerProtocol
    ) -> URL? {
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectory
        }
        return nil
    }

    public static func getApplicationDirectory(
        fileManager: FileManagerProtocol
    ) -> URL? {
        if let applicationDirectory = fileManager.urls(for: .applicationDirectory, in: .userDomainMask).first {
            return applicationDirectory
        }
        return nil
    }

    public static func getConfigDirectory(from directory: URL? = nil, fileManager: FileManagerProtocol) throws -> URL {
        let baseDirectory = try directory ?? getCacheDirectory(fileManager: fileManager)
        return baseDirectory.appending(path:
            Constants.Configuration.CacheConfigFolder, directoryHint: .isDirectory
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
            let primaryLogsDirectory = mainDirectory.appending(path: "logs")

            if !fileManager.fileExists(atPath: primaryLogsDirectory.resolvedPath) {
                try fileManager.createDirectory(
                    at: primaryLogsDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                return primaryLogsDirectory.appending(path: libdigidocppLogFile)
            } else {
                return primaryLogsDirectory.appending(path: libdigidocppLogFile)
            }
        }

        let cacheDirectory = try getCacheDirectory(fileManager: fileManager)
        let fallbackLogsDirectory = cacheDirectory.appending(path: "logs")

        if !fileManager.fileExists(atPath: fallbackLogsDirectory.resolvedPath) {
            try fileManager.createDirectory(
                at: fallbackLogsDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        return fallbackLogsDirectory.appending(path: libdigidocppLogFile)
    }
}
