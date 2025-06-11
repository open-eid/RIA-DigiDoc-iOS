import Foundation
import Testing
import CommonsLib
import CommonsTestShared

@testable import UtilsLib

struct MimeTypeCacheTests {

    private let mockFileManager: FileManagerProtocolMock!
    private let mockFileUtil: FileUtilProtocolMock!

    private var mimeTypeCache: MimeTypeCacheProtocol!
    private var tempDirectory: URL!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        mockFileUtil = FileUtilProtocolMock()
        mimeTypeCache = await MimeTypeCache(fileUtil: mockFileUtil)
        mockFileManager = FileManagerProtocolMock()
    }

    @Test
    @MainActor
    func getMimeType_setAndGetFromCache() async throws {
        let mockFileUrl = URL(fileURLWithPath: "/mock/path")
        let md5 = "0cbc6611f5540bd0809a388dc95a615b"
        let expectedMimeType = "text/plain"

        mockFileUtil.getMimeTypeFromZipFileHandler = { _, _, _ in expectedMimeType }

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)

        #expect(expectedMimeType == mimeType)
    }

    @Test
    func getMimeType_getMimetypeBeforeAndAfterCaching() async throws {
        let mockFileUrl = URL(fileURLWithPath: "/mock/path")
        let md5 = "0cbc6611f5540bd0809a388dc95a615b"
        let expectedMimeType = "text/plain"

        mockFileUtil.getMimeTypeFromZipFileHandler = { _, _, _ in expectedMimeType }

        let initialCacheMiss = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)
        #expect(expectedMimeType == initialCacheMiss)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)

        #expect(expectedMimeType == mimeType)

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)
        let cachedMimeType = await mimeTypeCache.getMimeType(fileUrl: mockFileUrl)
        #expect(expectedMimeType == cachedMimeType)
    }
}
