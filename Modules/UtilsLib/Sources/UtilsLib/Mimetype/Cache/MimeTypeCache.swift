import Foundation
import CommonsLib

actor MimeTypeCache: MimeTypeCacheProtocol {
    private var cache: [String: MimeTypeCacheEntry] = [:]

    private let fileUtil: FileUtilProtocol
    private let fileManager: FileManagerProtocol
    private let mimetypeDecoder: MimeTypeDecoderProtocol

    init(
        fileUtil: FileUtilProtocol,
        fileManager: FileManagerProtocol,
        mimetypeDecoder: MimeTypeDecoderProtocol
    ) {
        self.fileUtil = fileUtil
        self.fileManager = fileManager
        self.mimetypeDecoder = mimetypeDecoder
    }

    func getMimeType(fileUrl: URL) async -> String {
        let md5 = fileUrl.md5Hash()

        if let cachedEntry = cache[md5]?.mimeType {
            return cachedEntry
        } else {
            let mimeType = await fileUrl.mimeType(
                fileUtil: fileUtil,
                mimeTypeDecoder: mimetypeDecoder
            )
            setMimeType(md5: md5, mimeType: mimeType)
            return mimeType
        }
    }

    func setMimeType(md5: String, mimeType: String) {
        cache[md5] = MimeTypeCacheEntry(mimeType: mimeType)
    }
}
