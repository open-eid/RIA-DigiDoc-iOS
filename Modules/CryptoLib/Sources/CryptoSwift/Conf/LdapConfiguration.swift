// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public actor LdapConfiguration: LdapConfigurationProtocol {
    private var current = LdapSettings()

    public init() {}

    public func settings() -> LdapSettings {
        current
    }

    public func update(_ settings: LdapSettings) {
        current = settings
    }
}
