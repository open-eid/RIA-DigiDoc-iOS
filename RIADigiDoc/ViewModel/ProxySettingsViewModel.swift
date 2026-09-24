// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Alamofire
import CommonsLib
import Foundation
import LibdigidocLibSwift
import UtilsLib

@Observable
@MainActor
class ProxySettingsViewModel: ProxySettingsViewModelProtocol, Loggable {
    var proxyInfo: ProxyInfo = ProxyInfo()
    var portText: String = "80"

    // MARK: - Dependencies
    private let proxyUtil: ProxyUtilProtocol
    private let userAgentUtil: UserAgentUtilProtocol
    private let dataStore: DataStoreProtocol
    private let cryptoSetup: CryptoSetupProtocol

    init(
        proxyUtil: ProxyUtilProtocol,
        userAgentUtil: UserAgentUtilProtocol,
        dataStore: DataStoreProtocol,
        cryptoSetup: CryptoSetupProtocol
    ) {
        self.proxyUtil = proxyUtil
        self.userAgentUtil = userAgentUtil
        self.dataStore = dataStore
        self.cryptoSetup = cryptoSetup

        Task {
            await loadSettings()
        }
    }

    // MARK: - Init helpers

    private func loadSettings() async {
        self.proxyInfo = await proxyUtil.getProxyInfo()
        portText = String(proxyInfo.port)
    }

    // MARK: - Computed properties

    public var isPortTextValid: Bool {
        if portText.isEmpty { return true }
        if let portInt = Int(portText) {
            return proxyUtil.isPortValid(portInt)
        }
        return false
    }

    // MARK: - Setters

    public func saveSettings() async {
        await proxyUtil.saveSetting(proxyInfo: proxyInfo)
        await cryptoSetup.setCdoc2ProxyInfo(proxyInfo)
    }

    // MARK: - Check connection

    public func checkInternetAccess(session: Session? = nil) async -> Bool {
        var requestProxyInfo = proxyInfo
        if requestProxyInfo.option == .system {
            requestProxyInfo = proxyUtil.getSystemProxyInfo()
        }

        let url = "https://id.eesti.ee/config.json"
        let session = session ?? Session.withProxy(proxyInfo: requestProxyInfo)

        let appLanguage = await dataStore.getSelectedLanguage()
        let userAgent = userAgentUtil.userAgent(
            diagnostics: .none,
            language: appLanguage
        )

        let response = await session.request(
            url,
            headers: [
                .userAgent(userAgent)
            ]
        )
            .validate()
            .serializingData()
            .response

        if let statusCode = response.response?.statusCode, statusCode == 200 {
            return true
        } else {
            return false
        }
    }
}
