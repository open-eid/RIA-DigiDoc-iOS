// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol DataFilesViewModelProtocol: Sendable {
    func saveDataFile(dataFile: DataFileWrapper) async -> URL?
    func checkIfContainerFileExists(fileLocation: URL?) -> Bool
    func removeSavedFilesDirectory(savedFilesDirectory: URL?)
}
