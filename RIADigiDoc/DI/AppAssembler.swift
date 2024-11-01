import Swinject

@MainActor
class AppAssembler {
    static let shared = AppAssembler()

    let container: Container

    private init() {

        container = Container()

        // Register Repository
        container.register(SomeRepositoryProtocol.self) { _ in
            SomeRepository()
        }

        // Register Service
        container.register(SomeServiceProtocol.self) { resolver in
            guard let someRepository = resolver.resolve(SomeRepositoryProtocol.self) else {
                preconditionFailure("Unable to find SomeRepositoryProtocol")
            }
            return SomeService(someRepository: someRepository)
        }

        // Register ViewModel
        container.register(SomeViewModel.self) { resolver in
            guard let someService = resolver.resolve(SomeServiceProtocol.self) else {
                preconditionFailure("Unable to find SomeServiceProtocol")
            }
            return SomeViewModel(someService: someService)
        }

        container.register(LibrarySetup.self) { _ in
            return LibrarySetup()
        }
    }

    func resolve<T>(_: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            preconditionFailure("Unable to find \(T.Type.self)")
        }
        return resolved
    }
}
