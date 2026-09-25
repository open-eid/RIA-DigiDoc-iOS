// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Alamofire
import Foundation
import CommonsLib

/// @mockable
@MainActor
public protocol ProxySettingsViewModelProtocol: Sendable {
    var proxyInfo: ProxyInfo { get }
    var portText: String { get }
    var isPortTextValid: Bool { get }

    func saveSettings() async
    func checkInternetAccess(session: Session?) async -> Bool
}
