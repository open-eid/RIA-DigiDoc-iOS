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
import Testing
import CommonsLib
import CommonsTestShared
import UtilsLibMocks

@testable import UtilsLib

struct MimeTypeResolverTests {

    private let mockMimeTypeCache: MimeTypeCacheProtocolMock!
    private let resolver: MimeTypeResolverProtocol!

    init() async throws {
        mockMimeTypeCache = MimeTypeCacheProtocolMock()
        resolver = MimeTypeResolver(mimeTypeCache: mockMimeTypeCache)
    }

    @Test
    func mimeType_successUsingCacheToSetAndGet() async throws {
        let fileUrl = TestFileUtil.createSampleFile(name: "image", withExtension: "png")
        let expectedMimeType = "image/png"

        mockMimeTypeCache.getMimeTypeHandler = { _ in
            return expectedMimeType
        }

        let mimeType = await resolver.mimeType(url: fileUrl)

        #expect(expectedMimeType == mimeType)

        #expect(mockMimeTypeCache.getMimeTypeCallCount == 1)
        #expect(mockMimeTypeCache.getMimeTypeArgValues.first == fileUrl)
    }
}
