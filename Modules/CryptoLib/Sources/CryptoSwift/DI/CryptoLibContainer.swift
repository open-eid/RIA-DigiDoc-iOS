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
