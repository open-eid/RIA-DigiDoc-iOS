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

@Observable
@MainActor
class AdvancedSettingsViewModel: AdvancedSettingsViewModelProtocol {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "AdvancedSettingsViewModel")

    var configuration: ConfigurationProvider?

    private let dataStore: DataStoreProtocol
    private let keychainStore: KeychainStoreProtocol
    private let advancedSettingsRepository: AdvancedSettingsRepositoryProtocol
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let cryptoSetup: CryptoSetupProtocol

    public init(
        dataStore: DataStoreProtocol,
        keychainStore: KeychainStoreProtocol,
        advancedSettingsRepository: AdvancedSettingsRepositoryProtocol,
        configurationRepository: ConfigurationRepositoryProtocol,
        cryptoSetup: CryptoSetupProtocol
    ) {
        self.dataStore = dataStore
        self.keychainStore = keychainStore
        self.advancedSettingsRepository = advancedSettingsRepository
        self.configurationRepository = configurationRepository
        self.cryptoSetup = cryptoSetup

        Task {
            configuration = await configurationRepository.getConfiguration()
        }
    }

    // MARK: - Restore Default Settings

    public func restoreDefaultSettings() async {
        await dataStore.restoreDefaultServicesSettings(configuration)
        await keychainStore.removeAll()
        await removeCertificates()
        await DigiDocConf.restoreDefaultSettings()

        await cryptoSetup.setLdapConfig(configuration)
        await cryptoSetup.setCdoc2Config(configuration)
        await cryptoSetup.setCdoc2Settings(configuration)
    }

    private func removeCertificates() async {
        do {
            try await advancedSettingsRepository.removeAllCertFiles(certificateFolders: [
                CommonsLib.Constants.Folder.SiVaCert,
                CommonsLib.Constants.Folder.TSACert,
                CommonsLib.Constants.Folder.EncryptionKeyTransferCert
            ])
        } catch {
            AdvancedSettingsViewModel.logger.error("Unable to remove all certificates")
        }
    }

    func getIsRoleAndAddressEnabled() async -> Bool {
        await dataStore.getIsRoleAndAddressEnabled()
    }

    func setIsRoleAndAddressEnabled(_ isEnabled: Bool) async {
        await dataStore.setIsRoleAndAddressEnabled(isEnabled)
    }
}
