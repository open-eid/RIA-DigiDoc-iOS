import Foundation
import Testing
import Cuckoo
import CommonsLib
import CommonsTestShared

@testable import UtilsLib

final class MimeTypeResolverTests {

    private var mockMimeTypeCache: MockMimeTypeCacheProtocol!
    private var resolver: MimeTypeResolver!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        mockMimeTypeCache = MockMimeTypeCacheProtocol()
        resolver = MimeTypeResolver(mimeTypeCache: mockMimeTypeCache)
    }

    deinit {
        resolver = nil
        mockMimeTypeCache = nil
    }

    @Test
    func mimeType_successUsingCacheToSetAndGet() async throws {
        let fileUrl = TestFileUtil.createSampleFile(name: "image", withExtension: "png")
        let expectedMimeType = "image/png"

        stub(mockMimeTypeCache) { mock in
            when(mock.getMimeType(fileUrl: any())).thenReturn(expectedMimeType)
        }

        let md5Hash = fileUrl.md5Hash()
        stub(mockMimeTypeCache) { mock in
            when(mock.setMimeType(md5: equal(to: md5Hash), mimeType: equal(to: expectedMimeType))).thenDoNothing()
        }

        let mimeType = await resolver.mimeType(url: fileUrl)

        #expect(expectedMimeType == mimeType)
        verify(mockMimeTypeCache, times(1)).getMimeType(fileUrl: equal(to: fileUrl))
        verify(mockMimeTypeCache, times(1)).setMimeType(md5: equal(to: md5Hash), mimeType: equal(to: expectedMimeType))
    }
}
