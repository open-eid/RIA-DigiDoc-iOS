// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import System
import FactoryKit
import CommonsLib

/// @mockable
public protocol FileUtilProtocol: Sendable {
    func getFileFromZipFile(
        from zipFileURL: URL,
        fileNameToFind: String,
    ) async throws -> URL?

    func fileExists(fileLocation: URL?) -> Bool

    func getValidPath(url: URL) async -> URL?

    func getFileUrlFromAppGroup(_ url: URL, appGroupIdentifier: String) -> URL?

    func isFileFromiCloud(fileURL: URL) -> Bool

    func isFileDownloadedFromiCloud(fileURL: URL) -> Bool

    func downloadFileFromiCloud(fileURL: URL) async -> URL?

    func isFileInsideMailFolder(_ url: URL) -> Bool

    func getAllFileURLs(from folderURL: URL) -> [URL]

    func removeSharedFiles(url: URL?) throws

    func removeSavedFilesDirectory(savedFilesDirectory: URL?)

    func removeCacheLogsDirectory()

    func removeLibraryLogsDirectory(directory: URL?)
}
