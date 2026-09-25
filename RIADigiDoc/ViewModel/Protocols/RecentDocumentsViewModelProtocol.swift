// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import LibdigidocLibSwift
import CommonsLib

/// @mockable
@MainActor
public protocol RecentDocumentsViewModelProtocol: Sendable {
    func setChosenFiles(_ chosenFiles: Result<[URL], Error>)
    func loadFiles(from folderURL: URL, withExtensions extensions: [String])
    func deleteFile(_ file: FileItem)
}
