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
import LibdigidocLibSwift

public struct ProxyUtil: ProxyUtilProtocol {

    private let dataStore: DataStoreProtocol
    private let keychainStore: KeychainStoreProtocol

    public init(
        dataStore: DataStoreProtocol,
        keychainStore: KeychainStoreProtocol
    ) {
        self.dataStore = dataStore
        self.keychainStore = keychainStore
    }

    public func isPortValid(_ port: Int) -> Bool {
        return 1 <= port && port <= 65535
    }

    public func getProxyInfo() async -> ProxyInfo {
        var proxyInfo = await dataStore.getProxyInfo()

        if proxyInfo.option == .system {
            return getSystemProxyInfo()
        }

        let passwordData = await keychainStore.retrieve(key: .proxyPassword)
        if let passwordData, let password = String(data: passwordData, encoding: .utf8) {
            proxyInfo.password = password
        }
        return proxyInfo
    }

    public func saveSetting(proxyInfo: ProxyInfo) async {
        var proxyInfo = proxyInfo

        if proxyInfo.option == .disabled {
            proxyInfo = ProxyInfo()
        }
        if proxyInfo.option == .system {
            proxyInfo = getSystemProxyInfo()
        }

        await dataStore.setProxyInfo(proxyInfo)
        if proxyInfo.password.isEmpty {
            await keychainStore.remove(key: .proxyPassword)
        } else {
            let passwordData = Data(proxyInfo.password.utf8)
            _ = await keychainStore.save(key: .proxyPassword, info: passwordData)
        }
        DigiDocConf.setProxyInfo(proxyInfo: proxyInfo)
    }

    public func getSystemProxyInfo() -> ProxyInfo {
        var proxyInfo = ProxyInfo()
        proxyInfo.option = .system
        let proxySettingsUnmanaged = CFNetworkCopySystemProxySettings()
        if let proxySettingsUnmanaged {
            let proxySettings = proxySettingsUnmanaged.takeRetainedValue() as? [AnyHashable: Any]
            let systemHost = proxySettings?[kCFNetworkProxiesHTTPProxy] as? String
            let systemPort = proxySettings?[kCFNetworkProxiesHTTPPort] as? Int
            if let systemHost, let systemPort {
                proxyInfo.host = systemHost
                proxyInfo.port = systemPort
            }
        }
        return proxyInfo
    }
}
