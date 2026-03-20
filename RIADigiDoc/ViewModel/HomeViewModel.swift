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
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@Observable
@MainActor
class HomeViewModel: HomeViewModelProtocol, Loggable {
    var isImporting = false
    var signedContainer: SignedContainerProtocol = SignedContainer(
        fileManager: Container.shared.fileManager(),
        containerUtil: Container.shared.containerUtil()
    )

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileManager: FileManagerProtocol
    private let fileUtil: FileUtilProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileManager: FileManagerProtocol,
        fileUtil: FileUtilProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileManager = fileManager
        self.fileUtil = fileUtil
    }

    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool {
        if !isImportingValue && !isFileOpeningLoading {
            HomeViewModel.logger().info("User cancelled the file chooser")
            return true
        }

        return false
    }

    func setChosenFiles(_ chosenFiles: Result<[URL], Error>) {
        sharedContainerViewModel.setFileOpeningResult(fileOpeningResult: chosenFiles)
    }

    func setFileOpeningMethod(_ method: FileOpeningMethod) {
        sharedContainerViewModel.setFileOpeningMethod(method)
    }

    func getRecentDocumentsFolder() -> URL? {
        do {
            return try Directories.getCacheDirectory(fileManager: fileManager)
                .appending(path: Constants.Folder.ContainerFolder)
        } catch {
            HomeViewModel.logger().error("Unable to get signed containers recent documents folder: \(error)")
            return nil
        }
    }

    func getSharedFiles() async -> [URL] {
        do {
            HomeViewModel.logger().info("Checking for shared files...")
            let sharedFolderURL = try await Directories.getSharedFolder(fileManager: fileManager)
                .validURL(fileUtil: fileUtil)

            let contents = try fileManager.contentsOfDirectory(
                at: sharedFolderURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)

            if contents.isEmpty {
                HomeViewModel.logger().info("Shared files folder is empty")
            } else {
                HomeViewModel.logger().info("Found \(contents.count) shared files")
            }

            return contents
        } catch {
            HomeViewModel.logger().error("Unable to get shared files: \(error.localizedDescription)")
            return []
        }
    }
}
