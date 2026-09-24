// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import FactoryKit
import CryptoSwift
import CommonsLib
import UtilsLib

@Observable
@MainActor
class CryptoHomeViewModel: CryptoHomeViewModelProtocol, Loggable {

    var isImporting = false
    var signedContainer: CryptoContainerProtocol = CryptoContainer(
        fileManager: Container.shared.fileManager(),
        containerUtil: Container.shared.containerUtil()
    )

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileManager: FileManagerProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileManager = fileManager
    }

    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool {
        if !isImportingValue && !isFileOpeningLoading {
            CryptoHomeViewModel.logger().info("User cancelled the file chooser")
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
            CryptoHomeViewModel.logger().error("Unable to get crypto recent documents folder: \(error)")
            return nil
        }
    }
}
