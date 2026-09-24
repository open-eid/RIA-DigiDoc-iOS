// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import UtilsLib

/// @mockable
@MainActor
public protocol HomeViewModelProtocol: Sendable {
    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool
    func setChosenFiles(_ chosenFiles: Result<[URL], Error>)
    func getRecentDocumentsFolder() -> URL?
    func getSharedFiles() async -> [URL]
    func setFileOpeningMethod(_ method: FileOpeningMethod)
}
