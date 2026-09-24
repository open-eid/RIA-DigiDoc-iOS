// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import Foundation

extension Container {
    public var cryptoContainer: Factory<CryptoContainerProtocol> {
        self {
            CryptoContainer(
                fileManager: self.fileManager(),
                containerUtil: self.containerUtil()
            )
        }
    }

    @MainActor
    public var ldapConfiguration: Factory<LdapConfigurationProtocol> {
        self {
            @MainActor in LdapConfiguration(
                fileManager: self.fileManager()
            )
        }.singleton
    }

    @MainActor
    public var openLdap: Factory<OpenLdapProtocol> {
        self {
            @MainActor in OpenLdap(
                fileManager: self.fileManager(),
                ldapConfiguration: self.ldapConfiguration()
            )
        }
    }
}
