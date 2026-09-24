// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import ConfigLib

/// @mockable
public protocol CryptoSetupProtocol: Sendable {
    func setLdapConfig(_ configurationProvider: ConfigurationProvider?) async
    func setCdoc2Config(_ configurationProvider: ConfigurationProvider?) async
    func setCdoc2Settings(_ configurationProvider: ConfigurationProvider?) async
    func setCdoc2CustomCert(_ certData: Data?) async
    func setCdoc2ProxyInfo(_ proxyInfo: ProxyInfo) async
}
