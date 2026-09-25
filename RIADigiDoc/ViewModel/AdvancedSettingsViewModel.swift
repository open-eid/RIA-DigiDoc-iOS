// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import ConfigLib
import Foundation
import LibdigidocLibSwift
import UtilsLib

@Observable
@MainActor
class AdvancedSettingsViewModel: AdvancedSettingsViewModelProtocol, Loggable {
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
            AdvancedSettingsViewModel.logger().error("Unable to remove all certificates")
        }
    }

    func getIsRoleAndAddressEnabled() async -> Bool {
        await dataStore.getIsRoleAndAddressEnabled()
    }

    func setIsRoleAndAddressEnabled(_ isEnabled: Bool) async {
        await dataStore.setIsRoleAndAddressEnabled(isEnabled)
    }
}
