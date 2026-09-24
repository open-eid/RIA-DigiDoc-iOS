// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib

/// @mockable
@MainActor
public protocol ProxyUtilProtocol: Sendable {
    func isPortValid(_ port: Int) -> Bool
    func getProxyInfo() async -> ProxyInfo
    func saveSetting(proxyInfo: ProxyInfo) async
    func getSystemProxyInfo() -> ProxyInfo
}
