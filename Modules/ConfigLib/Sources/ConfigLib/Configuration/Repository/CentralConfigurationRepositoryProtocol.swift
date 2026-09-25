// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation

/// @mockable
public protocol CentralConfigurationRepositoryProtocol: Sendable {
    func fetchConfiguration(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String

    func fetchSignature(
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> String
}
