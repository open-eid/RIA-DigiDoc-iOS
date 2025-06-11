import Foundation

actor MimeTypeCache: MimeTypeCacheProtocol {
    private var cache: [String: MimeTypeCacheEntry] = [:]

    private let fileUtil: FileUtilProtocol

    @MainActor
    init(fileUtil: FileUtilProtocol = UtilsLibAssembler.shared.resolve(FileUtilProtocol.self)) {
        self.fileUtil = fileUtil
    }

    func getMimeType(fileUrl: URL) async -> String {
        let md5 = fileUrl.md5Hash()

        if let cachedEntry = cache[md5]?.mimeType {
            return cachedEntry
        } else {
            let mimeType = await fileUrl.mimeType(fileUtil: fileUtil)
            setMimeType(md5: md5, mimeType: mimeType)
            return mimeType
        }
    }

    func setMimeType(md5: String, mimeType: String) {
        cache[md5] = MimeTypeCacheEntry(mimeType: mimeType)
    }
}
