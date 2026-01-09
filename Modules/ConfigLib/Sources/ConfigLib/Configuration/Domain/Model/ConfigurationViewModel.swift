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
import UtilsLib
import CommonsLib

@MainActor
class ConfigurationViewModel: Loggable {

    private(set) var configuration: ConfigurationProvider?

    private let repository: ConfigurationRepositoryProtocol
    private let fileManager: FileManagerProtocol

    init(
        repository: ConfigurationRepositoryProtocol,
        fileManager: FileManagerProtocol
    ) {
        self.repository = repository
        self.fileManager = fileManager
    }

    func fetchConfiguration(
        lastUpdate: TimeInterval,
        proxyInfo: ProxyInfo,
        userAgent: String
    ) async {
        do {
            guard let updates = try await repository.getCentralConfigurationUpdates(
                cacheDir: Directories.getConfigDirectory(fileManager: fileManager),
                proxyInfo: proxyInfo,
                userAgent: userAgent
            ) else {
                ConfigurationViewModel.logger().error("No configuration updates available.")
                return
            }

            for try await config in updates {
                if let configurationProvider = config {
                    let confUpdateDate = configurationProvider.configurationUpdateDate
                    if lastUpdate == 0 || (confUpdateDate?.timeIntervalSince1970 ?? 0) > lastUpdate {
                        self.configuration = configurationProvider
                    }
                }
            }
        } catch {
            ConfigurationViewModel.logger().error("Unable to fetch configuration: \(error.localizedDescription)")
        }
    }

    func getConfiguration() async -> ConfigurationProvider? {
        do {
            guard let updates = await repository.getConfigurationUpdates() else {
                ConfigurationViewModel.logger().error("Configuration updates provider is nil")
                return nil
            }

            for try await config in updates {
                if let configurationProvider = config {
                    return configurationProvider
                }
            }
        } catch {
            ConfigurationViewModel.logger().error("Unable to get configuration: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
}
