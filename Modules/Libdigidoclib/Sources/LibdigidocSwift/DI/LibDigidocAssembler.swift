import Swinject

@MainActor
public class LibDigidocAssembler {
    public static let shared = LibDigidocAssembler()

    let container: Container

    private init() {

        container = Container()

        container.register(DigiDocConfProtocol.self) { _ in
            DigiDocConf()
        }
    }

    public func resolve<T>(_: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            preconditionFailure("Unable to find \(T.Type.self)")
        }
        return resolved
    }
}
