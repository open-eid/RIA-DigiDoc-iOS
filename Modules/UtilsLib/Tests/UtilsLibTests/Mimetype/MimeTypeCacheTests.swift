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

        mockFileUtil.getMimeTypeFromZipFileHandler = { _, _ in expectedMimeType }

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)

        #expect(expectedMimeType == mimeType)
    }

    @Test
    func getMimeType_getMimetypeBeforeAndAfterCaching() async throws {
        let mockFileUrl = URL(fileURLWithPath: "/mock/path")
        let md5 = "0cbc6611f5540bd0809a388dc95a615b"
        let expectedMimeType = "text/plain"

        mockFileUtil.getMimeTypeFromZipFileHandler = { _, _ in expectedMimeType }

        let initialCacheMiss = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)
        #expect(expectedMimeType == initialCacheMiss)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)

        #expect(expectedMimeType == mimeType)

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)
        let cachedMimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)
        #expect(expectedMimeType == cachedMimeType)
    }
}
