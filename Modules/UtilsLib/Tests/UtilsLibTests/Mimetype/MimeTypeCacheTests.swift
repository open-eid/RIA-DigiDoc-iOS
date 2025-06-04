import Foundation
import Testing
import CommonsLib
import CommonsTestShared

@testable import UtilsLib

struct MimeTypeCacheTests {

    private var mimeTypeCache: MimeTypeCacheProtocol!
    private var tempDirectory: URL!

    init() async throws {
        await UtilsLibAssembler.shared.initialize()

        mimeTypeCache = MimeTypeCache()
    }

    @Test
    func getMimeType_setAndGetFromCache() async throws {
        let fileUrl = TestFileUtil.createSampleFile()
        let md5 = fileUrl.md5Hash()
        let expectedMimeType = "text/plain"

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: fileUrl)

        #expect(expectedMimeType == mimeType)

        try? FileManager.default.removeItem(at: fileUrl)
    }

    @Test
    func getMimeType_getMimetypeBeforeAndAfterCaching() async throws {
        let fileUrl = TestFileUtil.createSampleFile(name: "image", withExtension: "png")
        let md5 = fileUrl.md5Hash()
        let expectedMimeType = await fileUrl.mimeType()

        let initialCacheMiss = await mimeTypeCache.getMimeType(fileUrl: fileUrl)
        #expect(expectedMimeType == initialCacheMiss)

        let mimeType = await mimeTypeCache.getMimeType(fileUrl: fileUrl)

        #expect(expectedMimeType == mimeType)

        await mimeTypeCache.setMimeType(md5: md5, mimeType: expectedMimeType)
        let cachedMimeType = await mimeTypeCache.getMimeType(fileUrl: fileUrl)
        #expect(expectedMimeType == cachedMimeType)

        try? FileManager.default.removeItem(at: fileUrl)
    }
}
