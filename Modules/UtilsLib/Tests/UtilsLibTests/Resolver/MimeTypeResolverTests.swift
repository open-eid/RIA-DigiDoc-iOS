import Foundation
import Testing
import CommonsLib
import CommonsTestShared

@testable import UtilsLib

struct MimeTypeResolverTests {

    private var mockMimeTypeCache: MimeTypeCacheProtocolMock!
    private var resolver: MimeTypeResolverProtocol!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        mockMimeTypeCache = MimeTypeCacheProtocolMock()
        resolver = MimeTypeResolver(mimeTypeCache: mockMimeTypeCache)
    }

    @Test
    func mimeType_successUsingCacheToSetAndGet() async throws {
        let fileUrl = TestFileUtil.createSampleFile(name: "image", withExtension: "png")
        let expectedMimeType = "image/png"

        mockMimeTypeCache.getMimeTypeHandler = { @Sendable _ in
            return expectedMimeType
        }

        let mimeType = await resolver.mimeType(url: fileUrl)

        #expect(expectedMimeType == mimeType)

        #expect(mockMimeTypeCache.getMimeTypeCallCount == 1)
        #expect(mockMimeTypeCache.getMimeTypeArgValues.first == fileUrl)
    }
}
