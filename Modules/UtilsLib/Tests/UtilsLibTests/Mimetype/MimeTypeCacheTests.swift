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
import UtilsLibMocks
import Testing
import CommonsLib
import CommonsTestShared
import CommonsLibMocks

@testable import UtilsLib

struct MimeTypeCacheTests {

    private let mockFileManager: FileManagerProtocolMock!
    private let mockFileUtil: FileUtilProtocolMock!
    private let mockMimetypeDecoder: MimeTypeDecoderProtocolMock!

    private let mimeTypeCache: MimeTypeCacheProtocol!

    init() async throws {
        mockFileUtil = FileUtilProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockMimetypeDecoder = MimeTypeDecoderProtocolMock()
        mimeTypeCache = MimeTypeCache(
            fileUtil: mockFileUtil,
            fileManager: mockFileManager,
            mimetypeDecoder: mockMimetypeDecoder
        )
    }

    @Test
    @MainActor
    func getMimeType_setAndGetFromCache() async throws {
        let mockFileUrl = URL(fileURLWithPath: "/mock/path")
        let md5 = "0cbc6611f5540bd0809a388dc95a615b"
        let expectedMimeType = "text/plain"

        mockFileUtil.getFileFromZipFileHandler = { _, _ in mockFileUrl }

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)

        #expect(expectedMimeType == mimeType)
    }

    @Test
    func getMimeType_getMimetypeBeforeAndAfterCaching() async throws {
        let mockFileUrl = URL(fileURLWithPath: "/mock/path")
        let md5 = "0cbc6611f5540bd0809a388dc95a615b"
        let expectedMimeType = "text/plain"

        mockFileUtil.getFileFromZipFileHandler = { _, _ in mockFileUrl }

        let initialCacheMiss = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)
        #expect(expectedMimeType == initialCacheMiss)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)

        #expect(expectedMimeType == mimeType)

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)
        let cachedMimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)
        #expect(expectedMimeType == cachedMimeType)
    }
}
