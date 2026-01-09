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
