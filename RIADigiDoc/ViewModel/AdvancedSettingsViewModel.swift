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

import CommonsLib
import ConfigLib
import Foundation
import LibdigidocLibSwift
import OSLog

@MainActor
class AdvancedSettingsViewModel: AdvancedSettingsViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "AdvancedSettingsViewModel")

    @Published var configuration: ConfigurationProvider?
    @Published var checkedAskRoleAndAddress: Bool = false

    private var configurationObservationTask: Task<Void, Never>?

    private let dataStore: DataStoreProtocol
    private let keychainStore: KeychainStoreProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let configurationRepository: ConfigurationRepositoryProtocol

    public init(
        dataStore: DataStoreProtocol,
        keychainStore: KeychainStoreProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol,
        configurationRepository: ConfigurationRepositoryProtocol
    ) {
        self.dataStore = dataStore
        self.keychainStore = keychainStore
        self.advancedSettingsRepository = advancedSettingsRepository
        self.configurationRepository = configurationRepository

        configurationObservationTask = Task {
            await observeConfigurationUpdates()
        }
    }

    // MARK: - Init helpers

    private func ensureConfigurationLoaded() async {
        if configuration == nil {
            for await config in $configuration.values where config != nil {
                break
            }
        }
    }

    // MARK: - Restore Default Settings

    public func restoreDefaultSettings() async {
        checkedAskRoleAndAddress = false
        await dataStore.restoreDefaultServicesSettings()
        await keychainStore.removeAll()
        await removeCertificates()
        await restoreLibDigidocDefaultValues()
    }

    private func removeCertificates() async {
        do {
            try await advancedSettingsRepository.removeAllCertFiles(certificateFolders: [
                CommonsLib.Constants.Folder.SivaCert,
                CommonsLib.Constants.Folder.TSACert,
                CommonsLib.Constants.Folder.EncryptionKeyTransferCert
            ])
        } catch {
            AdvancedSettingsViewModel.logger.error("Unable to remove all certificates")
        }
    }

    private func restoreLibDigidocDefaultValues() async {
        await ensureConfigurationLoaded()
        let defaultSiVaUrl = configuration?.sivaUrl
        let defaultTSUrl = configuration?.tsaUrl
        guard let defaultSiVaUrl, let defaultTSUrl else {
            AdvancedSettingsViewModel.logger.error("Unable get default urls from configuration")
            return
        }
        await DigiDocConf.restoreDefaultSettings(
            defaultSiVaUrl: defaultSiVaUrl,
            defaultTSUrl: defaultTSUrl
        )
    }

    // MARK: - Observer

    public func removeObservers() async {
        configurationObservationTask?.cancel()
    }

    public func observeConfigurationUpdates() async {
        guard !Task.isCancelled else {
            return
        }

        guard let configStream = await configurationRepository.observeConfigurationUpdates() else {
            AdvancedSettingsViewModel.logger.error("Unable to get configuration updates stream")
            return
        }

        do {
            for try await config in configStream {
                await MainActor.run {
                    configuration = config
                }
            }
        } catch {
            AdvancedSettingsViewModel.logger.error("Unable to get configuration from stream")
        }
    }

}
