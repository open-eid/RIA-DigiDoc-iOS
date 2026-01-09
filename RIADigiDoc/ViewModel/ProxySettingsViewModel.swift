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

    init(
        proxyUtil: ProxyUtilProtocol,
        userAgentUtil: UserAgentUtilProtocol,
        dataStore: DataStoreProtocol
    ) {
        self.proxyUtil = proxyUtil
        self.userAgentUtil = userAgentUtil
        self.dataStore = dataStore

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
