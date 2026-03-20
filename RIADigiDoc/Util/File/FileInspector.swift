/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
