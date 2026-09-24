// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

@Observable
@MainActor
class DataFilesViewModel: DataFilesViewModelProtocol, Loggable {

    private let sharedContainerViewModel: SharedContainerViewModelProtocol
    private let fileManager: FileManagerProtocol

    init(
        sharedContainerViewModel: SharedContainerViewModelProtocol,
        fileManager: FileManagerProtocol,
    ) {
        self.sharedContainerViewModel = sharedContainerViewModel
        self.fileManager = fileManager
    }

    func saveDataFile(dataFile: DataFileWrapper) async -> URL? {
        do {
            return try await (sharedContainerViewModel
                .currentContainer() as? any SignedContainerProtocol)?
                .saveDataFile(dataFile: dataFile, to: nil)
        } catch {
            DataFilesViewModel.logger().error(
                "Unable to save datafile \(dataFile.fileName): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func checkIfContainerFileExists(fileLocation: URL?) -> Bool {
        guard let file = fileLocation else { return false }
        return fileManager.fileExists(atPath: file.resolvedPath)
    }

    func removeSavedFilesDirectory(savedFilesDirectory: URL? = nil) {
        do {
            let directory = try savedFilesDirectory ?? Directories.getCacheDirectory(
                subfolders: [CommonsLib.Constants.Folder.SavedFiles],
                fileManager: fileManager
            )
            try fileManager.removeItem(at: directory)
            DataFilesViewModel.logger().info("Saved Files directory removed")
        } catch {
            DataFilesViewModel.logger().error("Unable to delete saved files directory: \(error.localizedDescription)")
        }
    }
}
