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
import OSLog
import CommonsLib

@Observable
@MainActor
class RecentDocumentsViewModel: RecentDocumentsViewModelProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "RecentDocumentsViewModel")

    var isImporting = false
    var files: [FileItem] = []
    var searchText: String = ""
    var errorMessage: String = ""

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    private let fileManager: FileManagerProtocol
    private let fileInspector: FileInspectorProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileManager: FileManagerProtocol,
        fileInspector: FileInspectorProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileManager = fileManager
        self.fileInspector = fileInspector
    }

    func filteredFiles(using extensions: [String]) -> [FileItem] {
        let sortedFiles = files.sorted { $0.lastOpened > $1.lastOpened }
        return sortedFiles.filter { file in
            extensions.contains(file.url.pathExtension.lowercased()) &&
                (searchText.isEmpty || file.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    func setChosenFiles(_ chosenFiles: Result<[URL], Error>) {
        sharedContainerViewModel.setFileOpeningResult(fileOpeningResult: chosenFiles)
    }

    func loadFiles(from folderURL: URL, withExtensions extensions: [String]) {
        do {
            var isDirectory = ObjCBool(true)
            guard fileManager.fileExists(atPath: folderURL.resolvedPath, isDirectory: &isDirectory) else { return }

            let fileURLs = try fileManager.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.contentAccessDateKey],
                options: .skipsHiddenFiles
            )
            files = try fileURLs.compactMap { url in
                guard extensions.contains(url.pathExtension.lowercased()) else {
                    return nil
                }

                let lastOpened = try fileInspector.lastOpened(for: url)

                return FileItem(
                    name: url.lastPathComponent,
                    url: url,
                    lastOpened: lastOpened
                )
            }
        } catch {
            files = []
            errorMessage = "Could not load selected files"
            RecentDocumentsViewModel.logger.error("Unable to load files: \(error)")
        }
    }

    func deleteFile(_ file: FileItem) {
        do {
            try fileManager.removeItem(at: file.url)
            files.removeAll { $0.url == file.url }
        } catch {
            errorMessage = "Failed to remove file"
            RecentDocumentsViewModel.logger.error("Unable to delete file: \(error)")
        }
    }
}
