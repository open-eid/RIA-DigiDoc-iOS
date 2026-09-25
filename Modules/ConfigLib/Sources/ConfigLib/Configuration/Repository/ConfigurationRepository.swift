// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Alamofire
import UtilsLib
import CommonsLib

public actor ConfigurationRepository: ConfigurationRepositoryProtocol {

    private let configurationLoader: ConfigurationLoaderProtocol
    private let fileManager: FileManagerProtocol

    private var continuation: AsyncThrowingStream<ConfigurationProvider?, Error>?

    public init(
        configurationLoader: ConfigurationLoaderProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.configurationLoader = configurationLoader
        self.fileManager = fileManager
    }

    public func getConfiguration() async -> ConfigurationProvider? {
        return await configurationLoader.getConfiguration()
    }

    public func getConfigurationUpdates() async -> AsyncThrowingStream<ConfigurationProvider?, Error>? {
        return await configurationLoader.getConfigurationUpdates(replayLatest: true)
    }

    public func getCentralConfiguration(
        cacheDir: URL?,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> ConfigurationProvider? {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        try await configurationLoader
            .loadCentralConfiguration(
                cacheDir: configDir,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )

        return await getConfiguration()
    }

    public func getCentralConfigurationUpdates(
        cacheDir: URL?,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async throws -> AsyncThrowingStream<
        ConfigurationProvider?,
        Error
    >? {
        let configDir = try cacheDir ?? Directories.getConfigDirectory(fileManager: fileManager)

        try await configurationLoader
            .loadCentralConfiguration(
                cacheDir: configDir,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )

        return await getConfigurationUpdates()
    }

    public func observeConfigurationUpdates(
    ) async -> AsyncThrowingStream<ConfigurationProvider?, Error>? {
        return await configurationLoader.getConfigurationUpdates(replayLatest: true)
    }
}
