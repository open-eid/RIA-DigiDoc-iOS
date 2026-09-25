// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum FileOpeningError: Error {
    case unableToRetrieveFileSize
    case invalidFileSize
    case emptyFile
    case noDataFiles
}
