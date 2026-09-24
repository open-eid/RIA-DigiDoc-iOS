// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

/// @mockable
public protocol ConfigurationLoaderProtocol: Sendable {
    func initConfiguration(
        configDir: URL,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws

    func loadConfigurationProperty() async throws -> ConfigurationProperty

    func loadCachedConfiguration(afterCentralCheck: Bool, cacheDir: URL?) async throws

    func loadDefaultConfiguration(cacheDir: URL?) async throws

    func loadCentralConfiguration(
        cacheDir: URL?,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws

    func shouldCheckForUpdates() async throws -> Bool

    func getConfiguration() async -> ConfigurationProvider?

    func getConfigurationUpdates(replayLatest: Bool) async -> AsyncThrowingStream<ConfigurationProvider?, Error>
}
