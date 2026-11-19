// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol LdapConfigurationProtocol: Sendable {
    func settings() async -> LdapSettings
    func update(_ settings: LdapSettings) async
}
