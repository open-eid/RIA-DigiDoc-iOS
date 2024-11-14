import Swinject

@MainActor
class AppAssembler {
    static let shared = AppAssembler()

    let container: Container

    private init() {
        container = Container()
    }

    func initialize() async {
        await setup()
    }

    // swiftlint:disable:next function_body_length
    private func setup() async {

        // Register Service
        container.register(SomeServiceProtocol.self) { _ in
            return SomeService()
        }

        // Register Repository
        container.register(SomeRepositoryProtocol.self) { resolver in
            guard let someService = resolver.resolve(SomeServiceProtocol.self) else {
                preconditionFailure("Unable to find SomeServiceProtocol")
            }
            return SomeRepository(someService: someService)
        }

        // Register ViewModel
        container.register(SomeViewModel.self) { resolver in
            guard let someRepository = resolver.resolve(SomeRepositoryProtocol.self) else {
                preconditionFailure("Unable to find SomeRepositoryProtocol")
            }
            return SomeViewModel(someRepository: someRepository)
        }

        container.register(LibrarySetup.self) { _ in
            return LibrarySetup()
        }.inObjectScope(.container)

        container.register(FileOpeningServiceProtocol.self) { _ in
            return FileOpeningService()
        }

        container.register(FileOpeningRepositoryProtocol.self) { resolver in
            guard let fileOpeningService = resolver.resolve(FileOpeningServiceProtocol.self) else {
                preconditionFailure("Unable to find FileOpeningServiceProtocol")
            }
            return FileOpeningRepository(fileOpeningService: fileOpeningService)
        }

        container.register(SharedContainerViewModel.self) { _ in
            return SharedContainerViewModel()
        }.inObjectScope(.container)

        container.register(MainSignatureViewModel.self) { resolver in
            guard let sharedContainerViewModel = resolver.resolve(SharedContainerViewModel.self) else {
                preconditionFailure("Unable to find SharedContainerViewModel")
            }
            return MainSignatureViewModel(sharedContainerViewModel: sharedContainerViewModel)
        }

        container.register(FileOpeningViewModel.self) { resolver in
            guard let fileOpeningRepository = resolver.resolve(FileOpeningRepositoryProtocol.self) else {
                preconditionFailure("Unable to find FileOpeningRepositoryProtocol")
            }

            guard let sharedContainerViewModel = resolver.resolve(SharedContainerViewModel.self) else {
                preconditionFailure("Unable to find SharedContainerViewModel")
            }
            return FileOpeningViewModel(
                fileOpeningRepository: fileOpeningRepository,
                sharedContainerViewModel: sharedContainerViewModel)
        }

        container.register(SigningViewModel.self) { resolver in
            guard let sharedContainerViewModel = resolver.resolve(SharedContainerViewModel.self) else {
                preconditionFailure("Unable to find SharedContainerViewModel")
            }
            return SigningViewModel(sharedContainerViewModel: sharedContainerViewModel)
        }.inObjectScope(.graph)

        container.register(LanguageSettingsProtocol.self) { _ in
            return LanguageSettings()
        }
    }

    func resolve<T>(_: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            preconditionFailure("Unable to find \(T.Type.self)")
        }
        return resolved
    }
}
