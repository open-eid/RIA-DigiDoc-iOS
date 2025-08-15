import Foundation
import FactoryKit

extension Container {
    public var configurationSignatureVerifier: Factory<ConfigurationSignatureVerifierProtocol> {
        self { ConfigurationSignatureVerifier() }
    }

    public var configurationProperties: Factory<ConfigurationPropertiesProtocol> {
        self { ConfigurationProperties() }
    }

    public var configurationProperty: Factory<ConfigurationProperty> {
        self { ConfigurationProperty(
            centralConfigurationServiceUrl: "",
            updateInterval: 0,
            versionSerial: 0,
            downloadDate: Date.now
        ) }
        .shared
    }

    public var centralConfigurationService: Factory<CentralConfigurationServiceProtocol> {
        self { CentralConfigurationService(
            userAgent: "",
            configurationProperty: self.configurationProperty(),
            session: nil
        ) }
    }

    public var centralConfigurationRepository: Factory<CentralConfigurationRepositoryProtocol> {
        self { CentralConfigurationRepository(
            centralConfigurationService: self.centralConfigurationService())
        }
    }

    public var configurationLoader: Factory<ConfigurationLoaderProtocol> {
        self {
            ConfigurationLoader(
                centralConfigurationRepository: self.centralConfigurationRepository(),
                configurationProperty: self.configurationProperty(),
                configurationProperties: self.configurationProperties(),
                configurationSignatureVerifier: self.configurationSignatureVerifier(),
                configurationCache: self.configurationCache(),
                fileManager: self.fileManager(),
                bundle: Bundle.module
            )
        }
        .shared
    }

    public var configurationRepository: Factory<ConfigurationRepositoryProtocol> {
        self {
            ConfigurationRepository(
                configurationLoader: self.configurationLoader(),
                fileManager: self.fileManager()
            )
        }
    }

    @MainActor
    var configurationViewModel: Factory<ConfigurationViewModel> {
        self {
            @MainActor in ConfigurationViewModel(
                repository: self.configurationRepository(),
                fileManager: self.fileManager()
            )
        }
    }

    var configurationCache: Factory<ConfigurationCacheProtocol> {
        self {
            ConfigurationCache(
                fileManager: self.fileManager()
            )
        }
    }
}
