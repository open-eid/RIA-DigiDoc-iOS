import Foundation
import CommonsLib

struct MimeTypeResolver: MimeTypeResolverProtocol {

    private let mimeTypeCache: MimeTypeCacheProtocol

    init(mimeTypeCache: MimeTypeCacheProtocol) {
        self.mimeTypeCache = mimeTypeCache
    }

    public func mimeType(url: URL) async -> String {
        let cachedMimeType = await mimeTypeCache.getMimeType(fileUrl: url)
        if cachedMimeType.isEmpty {
            return CommonsLib.Constants.MimeType.Default
        }
        return cachedMimeType
    }
}
