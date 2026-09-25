// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol LdapConfigurationProtocol: Sendable {
    func ldapCertsPath() async -> String?
    func getLdapPersonURLS() async -> [URL]
    func getLdapCorpURL() async -> URL?
    func setLdapPersonURLS(_ urls: [URL]) async
    func setLdapCorpURL(_ url: URL) async
}
