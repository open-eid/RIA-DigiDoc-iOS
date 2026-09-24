// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Alamofire
import CommonsLib
import Foundation

/// @mockable
public protocol CentralConfigurationServiceProtocol: Sendable {
    func fetchConfiguration(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String

    func fetchSignature(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String
}
