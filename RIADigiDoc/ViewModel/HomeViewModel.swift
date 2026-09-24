// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
