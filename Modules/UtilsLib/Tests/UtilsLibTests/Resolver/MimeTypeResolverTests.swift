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
