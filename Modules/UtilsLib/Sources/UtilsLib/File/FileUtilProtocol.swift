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
}
