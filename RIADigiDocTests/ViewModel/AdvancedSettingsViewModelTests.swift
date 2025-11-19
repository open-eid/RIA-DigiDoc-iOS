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

    let mockConfigProvider: ConfigurationProvider!

    init() async throws {
        mockDataStore = DataStoreProtocolMock()
        mockKeychainStore = KeychainStoreProtocolMock()
        mockAdvancedSettingsRepository = AdvancedSettingsRepositoryProtocolMock()
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()

        mockConfigProvider = try TestConfigurationProvider.mockConfigurationProvider()
        TestConfigurationSetup.configureMocks(
            configurationRepository: mockConfigurationRepository,
            configProvider: mockConfigProvider
        )

        viewModel = AdvancedSettingsViewModel(
            dataStore: mockDataStore,
            keychainStore: mockKeychainStore,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            configurationRepository: mockConfigurationRepository
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
