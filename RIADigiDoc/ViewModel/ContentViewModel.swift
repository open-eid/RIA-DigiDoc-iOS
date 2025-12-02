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
import OSLog
import FactoryKit
import UtilsLib
import CommonsLib

@Observable
@MainActor
class ContentViewModel: ContentViewModelProtocol {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "ContentViewModel")

    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol

    init(
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.fileUtil = fileUtil
        self.fileManager = fileManager
    }

    func getSharedFiles() async -> [URL] {
        do {
            ContentViewModel.logger.debug("Checking for shared files...")
            let sharedFolderURL = try await Directories.getSharedFolder(fileManager: fileManager)
                .validURL(fileUtil: fileUtil)

            let contents = try fileManager.contentsOfDirectory(
                at: sharedFolderURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)

            if contents.isEmpty {
                ContentViewModel.logger.debug("Shared files folder is empty")
            } else {
                ContentViewModel.logger.debug("Found \(contents.count) shared files")
            }

            return contents
        } catch {
            ContentViewModel.logger.error("Unable to get shared files: \(error.localizedDescription)")
            return []
        }
    }
}
