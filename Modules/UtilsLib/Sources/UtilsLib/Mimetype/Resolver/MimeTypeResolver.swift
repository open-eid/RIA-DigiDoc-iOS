import Foundation

struct MimeTypeResolver: MimeTypeResolverProtocol {

    private let mimeTypeCache: MimeTypeCacheProtocol

    init(mimeTypeCache: MimeTypeCacheProtocol) {
        self.mimeTypeCache = mimeTypeCache
    }

    func mimeType(url: URL) async -> String {
        let cachedMimeType = await mimeTypeCache.getMimeType(fileUrl: url)

        await mimeTypeCache.setMimeType(md5: url.md5Hash(), mimeType: cachedMimeType)

        return cachedMimeType
    }
}
