/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import Foundation
import CommonsLib
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
                bundle: self.bundle()
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

    public var tslUtil: Factory<TSLUtilProtocol> {
        self {
            TSLUtil(
                fileManager: self.fileManager()
            )
        }
    }

    public var bundle: Factory<BundleProtocol?> {
        self {
            Bundle.module
        }
    }
}
