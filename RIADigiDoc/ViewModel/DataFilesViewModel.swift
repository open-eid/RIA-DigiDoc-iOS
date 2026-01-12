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
