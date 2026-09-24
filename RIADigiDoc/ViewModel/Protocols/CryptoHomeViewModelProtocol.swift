// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol CryptoHomeViewModelProtocol: Sendable {
    func didUserCancelFileOpening(isImportingValue: Bool, isFileOpeningLoading: Bool) -> Bool
    func setChosenFiles(_ chosenFiles: Result<[URL], Error>)
    func getRecentDocumentsFolder() -> URL?
}
