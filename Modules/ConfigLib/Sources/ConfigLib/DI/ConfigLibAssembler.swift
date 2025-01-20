import Foundation
import Swinject

@MainActor
public struct ConfigLibAssembler {
    public static let shared = ConfigLibAssembler()

    private let container: Container

    private init() {
        container = Container()
    }

    public func initialize() async {
        await setup()
    }

    // swiftlint:disable:next function_body_length
    private func setup() async {

        container.register(ConfigurationSignatureVerifierProtocol.self) { _ in
            return ConfigurationSignatureVerifier()
        }

        container.register(ConfigurationPropertiesProtocol.self) { _ in
            return ConfigurationProperties()
        }

        container.register(ConfigurationProperty.self) { _ in
            return ConfigurationProperty(
                centralConfigurationServiceUrl: "",
                updateInterval: 0,
                versionSerial: 0,
                downloadDate: Date.now
            )
        }.inObjectScope(.container)

        container.register(CentralConfigurationServiceProtocol.self) { resolver in
            guard let configurationProperty = resolver.resolve(ConfigurationProperty.self) else {
                preconditionFailure("Unable to find ConfigurationProperty")
            }
            return CentralConfigurationService(
                userAgent: "",
                configurationProperty: configurationProperty,
                session: nil
            )
        }

        container.register(CentralConfigurationRepositoryProtocol.self) { resolver in
            guard let centralConfigurationService = resolver.resolve(CentralConfigurationServiceProtocol.self) else {
                preconditionFailure("Unable to find CentralConfigurationServiceProtocol")
            }
            return CentralConfigurationRepository(centralConfigurationService: centralConfigurationService)
        }

        container.register(ConfigurationLoaderProtocol.self) { resolver in
            guard let centralConfigurationRepository = resolver.resolve(
                CentralConfigurationRepositoryProtocol.self
            ) else {
                preconditionFailure(
                    "Unable to find CentralConfigurationRepository"
                )
            }
            guard let configurationProperty = resolver.resolve(ConfigurationProperty.self) else {
                preconditionFailure("Unable to find ConfigurationProperty")
            }
            guard let configurationProperties = resolver.resolve(ConfigurationPropertiesProtocol.self) else {
                preconditionFailure("Unable to find ConfigurationProperties")
            }
            guard let configurationSignatureVerifier = resolver.resolve(
                ConfigurationSignatureVerifierProtocol.self
            ) else {
                preconditionFailure(
                    "Unable to find ConfigurationSignatureVerifier"
                )
            }
            return ConfigurationLoader(
                centralConfigurationRepository: centralConfigurationRepository,
                configurationProperty: configurationProperty,
                configurationProperties: configurationProperties,
                configurationSignatureVerifier: configurationSignatureVerifier
            )
        }.inObjectScope(.container)

        container.register(ConfigurationRepositoryProtocol.self) { resolver in
            guard let configurationLoader = resolver.resolve(ConfigurationLoaderProtocol.self) else {
                preconditionFailure("Unable to find ConfigurationLoader")
            }
            return ConfigurationRepository(configurationLoader: configurationLoader)
        }

        container.register(ConfigurationViewModel.self) { resolver in
            guard let configurationRepository = resolver.resolve(ConfigurationRepositoryProtocol.self) else {
                preconditionFailure("Unable to find ConfigurationRepository")
            }
            return ConfigurationViewModel(repository: configurationRepository)
        }
    }

    public func resolve<T>(_: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            preconditionFailure("Unable to find \(T.Type.self)")
        }
        return resolved
    }
}
