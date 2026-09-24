// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import CommonsLib
import ConfigLib
import ConfigLibMocks
import Foundation
import Testing

@MainActor
final class AdvancedSettingsViewModelTests {
    private let viewModel: AdvancedSettingsViewModel!

    private let mockDataStore: DataStoreProtocolMock!
    private let mockKeychainStore: KeychainStoreProtocolMock!
    private let mockAdvancedSettingsRepository: AdvancedSettingsRepositoryProtocolMock!
    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock!
    private let mockCryptoSetup: CryptoSetupProtocolMock!

    let mockConfigProvider: ConfigurationProvider!

    init() async throws {
        mockDataStore = DataStoreProtocolMock()
        mockKeychainStore = KeychainStoreProtocolMock()
        mockAdvancedSettingsRepository = AdvancedSettingsRepositoryProtocolMock()
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockCryptoSetup = CryptoSetupProtocolMock()

        mockConfigProvider = try TestConfigurationProvider.mockConfigurationProvider()
        TestConfigurationSetup.configureMocks(
            configurationRepository: mockConfigurationRepository,
            configProvider: mockConfigProvider
        )

        viewModel = AdvancedSettingsViewModel(
            dataStore: mockDataStore,
            keychainStore: mockKeychainStore,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            configurationRepository: mockConfigurationRepository,
            cryptoSetup: mockCryptoSetup
        )
    }

    @Test
    func restoreDefaultSettings_success() async throws {
        await viewModel.restoreDefaultSettings()

        #expect(mockDataStore.restoreDefaultServicesSettingsCallCount == 1)
        #expect(mockKeychainStore.removeAllCallCount == 1)
        #expect(mockAdvancedSettingsRepository.removeAllCertFilesCallCount == 1)
        #expect(mockAdvancedSettingsRepository.removeAllCertFilesArgValues.first == [
            CommonsLib.Constants.Folder.SiVaCert,
            CommonsLib.Constants.Folder.TSACert,
            CommonsLib.Constants.Folder.EncryptionKeyTransferCert
        ])
    }

    @Test
    func restoreDefaultSettings_doesNotThrowWhenRemovingCertsFails() async throws {
        mockAdvancedSettingsRepository.removeAllCertFilesHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            await viewModel.restoreDefaultSettings()
            #expect(mockDataStore.restoreDefaultServicesSettingsCallCount == 1)
            #expect(mockKeychainStore.removeAllCallCount == 1)
            #expect(mockAdvancedSettingsRepository.removeAllCertFilesCallCount == 1)
            #expect(mockAdvancedSettingsRepository.removeAllCertFilesArgValues.first == [
                CommonsLib.Constants.Folder.SiVaCert,
                CommonsLib.Constants.Folder.TSACert,
                CommonsLib.Constants.Folder.EncryptionKeyTransferCert
            ])
        }
    }

    @Test
    func getIsRoleAndAddressEnabled_successWithTrue() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = { true }

        let isRoleAndAddressEnabled = await viewModel.getIsRoleAndAddressEnabled()

        #expect(isRoleAndAddressEnabled)
    }

    @Test
    func getIsRoleAndAddressEnabled_successWithFalse() async {
        mockDataStore.getIsRoleAndAddressEnabledHandler = { false }

        let isRoleAndAddressEnabled = await viewModel.getIsRoleAndAddressEnabled()

        #expect(!isRoleAndAddressEnabled)
    }

    @Test
    func setIsRoleAndAddressEnabled_success() async {
        await viewModel.setIsRoleAndAddressEnabled(true)

        #expect(mockDataStore.setIsRoleAndAddressEnabledCallCount == 1)
        #expect(mockDataStore.setIsRoleAndAddressEnabledArgValues.first == true)
    }
}
