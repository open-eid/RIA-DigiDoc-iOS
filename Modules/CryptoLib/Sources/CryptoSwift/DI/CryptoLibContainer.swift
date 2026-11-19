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
            @MainActor in LdapConfiguration()
        }.singleton
    }

    @MainActor
    public var ldapSearch: Factory<LdapSearchProtocol> {
        self {
            @MainActor in LdapSearch(
                ldapConfiguration: self.ldapConfiguration()
            )
        }
    }
}
