// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import Foundation

/// @mockable
public protocol ConfigurationRepositoryProtocol: Sendable {
    func getConfiguration() async -> ConfigurationProvider?

    func getCentralConfiguration(
        cacheDir: URL?,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> ConfigurationProvider?

    func observeConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>?

    func getConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>?

    func getCentralConfigurationUpdates(
        cacheDir: URL?,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> AsyncThrowingStream<
        ConfigurationProvider?,
        Error
    >?
}
