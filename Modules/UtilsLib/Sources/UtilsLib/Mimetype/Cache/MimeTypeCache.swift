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
import CommonsLib

actor MimeTypeCache: MimeTypeCacheProtocol {
    private var cache: [String: MimeTypeCacheEntry] = [:]

    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol
    private let mimetypeDecoder: MimeTypeDecoderProtocol

    init(
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol,
        mimetypeDecoder: MimeTypeDecoderProtocol
    ) {
        self.fileUtil = fileUtil
        self.fileManager = fileManager
        self.mimetypeDecoder = mimetypeDecoder
    }

    func getMimeType(fileUrl: URL) async -> String {
        let md5 = fileUrl.md5Hash()

        if let cachedEntry = cache[md5]?.mimeType {
            return cachedEntry
        } else {
            let mimeType = await fileUrl.mimeType(
                fileUtil: fileUtil,
                mimeTypeDecoder: mimetypeDecoder
            )
            setMimeType(md5: md5, mimeType: mimeType)
            return mimeType
        }
    }

    func setMimeType(md5: String, mimeType: String) {
        cache[md5] = MimeTypeCacheEntry(mimeType: mimeType)
    }
}
