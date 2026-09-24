// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import LibdigidocLibSwift

public struct ProxyUtil: ProxyUtilProtocol {

    let dataStore: DataStoreProtocol
    let keychainStore: KeychainStoreProtocol

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
