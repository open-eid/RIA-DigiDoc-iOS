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
import System
import ZIPFoundation
import FactoryKit
import CommonsLib

public struct FileUtil: FileUtilProtocol, Loggable {

    private let fileManager: FileManagerProtocol

    public init(
        fileManager: FileManagerProtocol
    ) {
        self.fileManager = fileManager
    }

    public func getFileFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String
    ) async throws -> URL? {
        let archive = try Archive(url: zipFileURL, accessMode: .read)

        if let entry = archive.first(where: { $0.path.contains(fileNameToFind) }) {
            let extractedFile = try await Directories
                .getTempDirectory(subfolder: Constants.Folder.Temp, fileManager: fileManager)
                .validURL(fileUtil: self)
                .appending(path: entry.path)

            if fileManager.fileExists(atPath: extractedFile.resolvedPath) {
                try fileManager.removeItem(at: extractedFile)
            }

            _ = try archive.extract(entry, to: extractedFile)

            return extractedFile
        }

        return nil
    }

    public func fileExists(fileLocation: URL?) -> Bool {
        guard let file = fileLocation else { return false }
        return fileManager.fileExists(atPath: file.resolvedPath)
    }

    // Check file path so its valid and is not modified by someone else
    public func getValidPath(url: URL) async -> URL? {
        FileUtil.logger().debug("Getting valid path for file: \(url)")

        let resolvedURL = url.resolvingSymlinksInPath()
        let filePath = FilePath(resolvedURL.resolvedPath).lexicallyNormalized()

        // The simulator uses different directories than a real iOS device
        if SystemUtil.isSimulator {
            return resolvedURL
        }

        let documentsDirectory: URL = Directories.getDocumentsDirectory(fileManager: fileManager) ?? URL(
            fileURLWithPath: "/var/mobile/Containers/Data/Application/"
        )

        let applicationDirectory: URL = Directories.getApplicationDirectory(fileManager: fileManager) ?? URL(
            fileURLWithPath: "/var/mobile/Containers/Data/Application/"
        )

        let containerBasePaths = [
            URL(fileURLWithPath: "/private/var/mobile/Containers/Data/Application/"),
            URL(fileURLWithPath: "/var/mobile/Containers/Data/Application/"),
            documentsDirectory,
            applicationDirectory
        ]

        for containerBasePath in containerBasePaths {
            let appContainerPath = FilePath(containerBasePath
                .resolvingSymlinksInPath()
                .resolvedPath)
                .lexicallyNormalized()

            if filePath.starts(with: appContainerPath) {
                FileUtil.logger().debug("Resolved valid file path: \(resolvedURL)")
                return resolvedURL
            }
        }

        // Check if file is opened externally (outside of application)
        let fileFromAppGroup = getFileUrlFromAppGroup(resolvedURL, appGroupIdentifier: Constants.Identifier.Group)
        if let fileUrl = fileFromAppGroup {
            FileUtil.logger().debug("File is from app group: \(fileUrl)")
            return fileUrl
        }

        if isFileInsideMailFolder(resolvedURL) {
            FileUtil.logger().debug("File is from Mail app")
            return resolvedURL
        } else {
            FileUtil.logger().debug("Checking if file is from iCloud")
            // Check if file is opened from iCloud
            if isFileFromiCloud(fileURL: resolvedURL) {
                if !isFileDownloadedFromiCloud(fileURL: resolvedURL) {
                    FileUtil.logger().debug(
                        "File '\(resolvedURL.lastPathComponent)' from iCloud is not downloaded. Downloading..."
                    )

                    let downloadedFileUrl = await downloadFileFromiCloud(fileURL: resolvedURL)
                    if let fileUrl = downloadedFileUrl {
                        FileUtil.logger().debug("File '\(resolvedURL.lastPathComponent)' downloaded from iCloud")
                        return fileUrl
                    } else {
                        FileUtil.logger().debug(
                            "Unable to download file '\(resolvedURL.lastPathComponent)' from iCloud")
                        return nil
                    }
                } else {
                    FileUtil.logger().debug("File '\(resolvedURL.lastPathComponent)' from iCloud is already downloaded")
                    return url
                }
            }
        }

        FileUtil.logger().debug("File is NOT from iCloud")
        return nil
    }

    public func getFileUrlFromAppGroup(_ url: URL, appGroupIdentifier: String) -> URL? {
        let resolvedURL = url.resolvingSymlinksInPath()
        let filePath = FilePath(resolvedURL.resolvedPath).lexicallyNormalized()

        guard let appGroupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            return nil
        }

        let resolvedAppGroupURL = appGroupURL.resolvingSymlinksInPath()
        let normalizedURL = URL(fileURLWithPath: String(decoding: filePath))
        let resolvedAppGroupFilePath = FilePath(
            stringLiteral: resolvedAppGroupURL.deletingLastPathComponent().resolvedPath
        )

        let isFromAppGroup = filePath.starts(with: resolvedAppGroupFilePath) ||
        filePath.starts(with: FilePath("/private")
            .appending(resolvedAppGroupFilePath.components)
        )

        if isFromAppGroup {
            FileUtil.logger().debug("File is from app group: \(normalizedURL)")
            return normalizedURL
        }

        return nil
    }

    public func isFileFromiCloud(fileURL: URL) -> Bool {
        do {
            let urlResourceValues = try fileURL.resourceValues(forKeys: [.isUbiquitousItemKey])

            if let isUbiquitousItem = urlResourceValues.isUbiquitousItem, isUbiquitousItem {
                return true
            }
        } catch {
            FileUtil.logger().error(
                "Unable to check iCloud file '\(fileURL.lastPathComponent)' status: \(error.localizedDescription)"
            )
        }

        return false
    }

    public func isFileDownloadedFromiCloud(fileURL: URL) -> Bool {
        do {
            let values = try fileURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])

            if let downloadingStatus = values.ubiquitousItemDownloadingStatus, downloadingStatus == .current {
                FileUtil.logger().debug("File downloaded from iCloud")
                return true
            }
        } catch {
            let errorMessage = String(
                format: "Unable to check iCloud file '%@' download status: %@",
                fileURL.lastPathComponent,
                error.localizedDescription
            )
            FileUtil.logger().error("\(errorMessage)")
        }

        return false
    }

    public func downloadFileFromiCloud(fileURL: URL) async -> URL? {
        do {
            try fileManager.startDownloadingUbiquitousItem(at: fileURL)
            FileUtil.logger().debug("Downloading file '\(fileURL.lastPathComponent)' from iCloud")

            while !isFileDownloadedFromiCloud(fileURL: fileURL) {
                try await Task.sleep(for: .seconds(0.5))
            }

            FileUtil.logger().debug("iCloud file '\(fileURL.lastPathComponent)' downloaded")
            return fileURL
        } catch {
            FileUtil.logger().error(
                "Unable to start iCloud file '\(fileURL.lastPathComponent)' download: \(error.localizedDescription)"
            )
            return nil
        }
    }

    public func isFileInsideMailFolder(_ url: URL) -> Bool {
        let mailFolderPath = FilePath(stringLiteral: "/var/mobile/Library/Mail").lexicallyNormalized()
        let filePath = FilePath(stringLiteral: url.resolvedPath).lexicallyNormalized()

        if filePath == mailFolderPath {
            FileUtil.logger().debug("File '\(url.lastPathComponent)' is from Mail app")
            return true
        }

        if filePath.starts(with: mailFolderPath) {
            let mailPathString = mailFolderPath.string
            let filePathString = filePath.string

            if filePathString.count == mailPathString.count {
                FileUtil.logger().debug("File '\(url.lastPathComponent)' is from Mail app")
                return true
            }

            let index = filePathString.index(filePathString.startIndex, offsetBy: mailPathString.count)
            if filePathString[index] == "/" {
                FileUtil.logger().debug("File '\(url.lastPathComponent)' is from Mail app")
                return true
            }
        }

        FileUtil.logger().debug("File '\(url.lastPathComponent)' is NOT from Mail app")

        return false
    }

    public func getAllFileURLs(from folderURL: URL) -> [URL] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: nil,
                options: []
            )
            return fileURLs
        } catch {
            return []
        }
    }

    public func removeSharedFiles(url: URL?) throws {
        FileUtil.logger().debug("Removing shared files")

        let sharedFilesFolder = try url ?? Directories.getSharedFolder(fileManager: fileManager)

        let contents = try sharedFilesFolder.folderContents(fileManager: fileManager)

        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }

        FileUtil.logger().debug("Shared files removed")
    }

    public func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        FileUtil.logger().debug("Removing saved files directory")
        do {
            let directory = try savedFilesDirectory ?? Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.SavedFiles,
                fileManager: fileManager
            )
            try fileManager.removeItem(at: directory)
            FileUtil.logger().debug("Saved Files directory removed")
        } catch {
            FileUtil.logger().error("Unable to delete saved files directory: \(error.localizedDescription)")
        }
    }
}
