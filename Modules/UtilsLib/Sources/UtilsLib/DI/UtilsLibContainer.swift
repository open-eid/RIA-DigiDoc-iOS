import FactoryKit

extension Container {
    public var mimeTypeDecoder: Factory<MimeTypeDecoderProtocol> {
        self { MimeTypeDecoder() }
    }

    public var fileUtil: Factory<FileUtilProtocol> {
        self { FileUtil(fileManager: self.fileManager()) }
    }

    public var mimeTypeResolver: Factory<MimeTypeResolverProtocol> {
        self { MimeTypeResolver(mimeTypeCache: self.mimeTypeCache()) }
    }

    public var mimeTypeCache: Factory<MimeTypeCacheProtocol> {
        self {
            MimeTypeCache(
                fileUtil: self.fileUtil(),
                fileManager: self.fileManager(),
                mimetypeDecoder: self.mimeTypeDecoder()
            )
        }
    }

    public var nameUtil: Factory<NameUtilProtocol> {
        self { NameUtil() }
    }
}
