// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct FileInspector: FileInspectorProtocol {

    public init() {}

    public func fileSize(for url: URL) throws -> Int {
        let resources = try url.resourceValues(forKeys: [.fileSizeKey])

        guard let fileSize = resources.fileSize, fileSize > 0 else {
            throw FileOpeningError.invalidFileSize
        }

        return fileSize
    }

    public func contentAccessDate(for url: URL) throws -> Date {
        let contentAccessDateResource = try url.resourceValues(forKeys: [.contentAccessDateKey])

        guard let contentAccessDate = contentAccessDateResource.contentAccessDate else {
            return Date()
        }

        return contentAccessDate
    }

    public func lastOpened(for url: URL) throws -> Date {
        try url.lastOpened() ?? contentAccessDate(for: url)
    }
}
