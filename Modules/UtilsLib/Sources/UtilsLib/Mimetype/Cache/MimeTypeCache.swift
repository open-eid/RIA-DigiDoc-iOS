import Foundation

actor MimeTypeCache: MimeTypeCacheProtocol {
    private var cache: [String: MimeTypeCacheEntry] = [:]

    func getMimeType(fileUrl: URL) async -> String {
        let md5 = fileUrl.md5Hash()

        if let cachedEntry = cache[md5]?.mimeType {
            return cachedEntry
        } else {
            let mimeType = fileUrl.mimeType()
            await setMimeType(md5: md5, mimeType: mimeType)
            return mimeType
        }
    }

    func setMimeType(md5: String, mimeType: String) async {
        cache[md5] = MimeTypeCacheEntry(mimeType: mimeType)
    }
}
