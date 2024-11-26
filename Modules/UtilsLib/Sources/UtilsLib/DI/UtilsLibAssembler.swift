import Swinject

@MainActor
public class UtilsLibAssembler {
    public static let shared = UtilsLibAssembler()

    private let container: Container

    private init() {
        container = Container()
    }

    public func initialize() async {
        await setup()
    }

    private func setup() async {

        container.register(MimeTypeCacheProtocol.self) { _ in
            return MimeTypeCache()
        }

        container.register(MimeTypeResolverProtocol.self) { resolver in
            guard let mimeTypeCache = resolver.resolve(MimeTypeCacheProtocol.self) else {
                preconditionFailure("Unable to find MimeTypeCacheProtocol")
            }
            return MimeTypeResolver(mimeTypeCache: mimeTypeCache)
        }

        container.register(MimeTypeDecoderProtocol.self) { _ in
            return MimeTypeDecoder()
        }

        container.register(FileUtilProtocol.self) { _ in
            return FileUtil()
        }
    }

    public func resolve<T>(_: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            preconditionFailure("Unable to find \(T.Type.self)")
        }
        return resolved
    }
}
