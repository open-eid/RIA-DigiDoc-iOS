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

import CommonsTestShared
import ConfigLib
import ConfigLibMocks
import Foundation
import Testing

@MainActor
final class EncryptionSettingsViewModelTests {
    private let viewModel: EncryptionSettingsViewModel!

    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock!
    private let mockDataStore: DataStoreProtocolMock!
    private let mockAdvancedSettingsRepository: AdvancedSettingsRepositoryProtocolMock!
    private let mockCertificateUtil: CertificateUtilProtocolMock!

    let mockConfigProvider: ConfigurationProvider!

    init() async throws {
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockDataStore = DataStoreProtocolMock()
        mockAdvancedSettingsRepository = AdvancedSettingsRepositoryProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()

        mockDataStore.getEncryptionCdocOptionHandler = {
            return .cdoc1
        }

        mockDataStore.getEncryptionUseKeyTransferHandler = {
            return false
        }

        mockDataStore.getEncryptionServerIdHandler = {
            return .defaultSetting
        }

        mockDataStore.getEncryptionServerInfoHandler = {
            return EncryptionServerInfo()
        }

        mockConfigProvider = try TestConfigurationProvider.mockConfigurationProvider()
        TestConfigurationSetup.configureMocks(
            configurationRepository: mockConfigurationRepository,
            configProvider: mockConfigProvider
        )

        viewModel = EncryptionSettingsViewModel(
            configurationRepository: mockConfigurationRepository,
            dataStore: mockDataStore,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            certificateUtil: mockCertificateUtil
        )
    }

    // MARK: - init tests

    @Test
    func init_successManualServerId() async throws {
        mockDataStore.getEncryptionServerIdHandler = {
            return .manualSetting
        }

        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )
        mockDataStore.getEncryptionServerInfoHandler = {
            return testServerInfo
        }

        let testViewModel = EncryptionSettingsViewModel(
            configurationRepository: mockConfigurationRepository,
            dataStore: mockDataStore,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            certificateUtil: mockCertificateUtil
        )

        await testViewModel.initializeSettings()

        #expect(testViewModel.serverInfo.uuid == testServerInfo.uuid)
        #expect(testViewModel.serverInfo.fetchURL == testServerInfo.fetchURL)
        #expect(testViewModel.serverInfo.postURL == testServerInfo.postURL)

    }

    // MARK: - saveSettings tests

    @Test
    func saveSettings_successWithCDOC1() async throws {
        viewModel.encryptionCdocOption = .cdoc1
        viewModel.useKeyTransfer = true
        viewModel.serverId = .manualSetting

        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )
        viewModel.serverInfo = testServerInfo

        await viewModel.saveSettings()

        #expect(mockDataStore.setEncryptionCdocOptionCallCount == 1)
        #expect(mockDataStore.setEncryptionUseKeyTransferCallCount == 1)
        #expect(mockDataStore.setEncryptionServerIdCallCount == 1)
        #expect(mockDataStore.setEncryptionServerInfoCallCount == 1)

        #expect(viewModel.encryptionCdocOption == .cdoc1)
        #expect(viewModel.useKeyTransfer == false)
        #expect(viewModel.serverId == .defaultSetting)
        #expect(viewModel.serverInfo.uuid != testServerInfo.uuid)
        #expect(viewModel.serverInfo.fetchURL != testServerInfo.fetchURL)
        #expect(viewModel.serverInfo.postURL != testServerInfo.postURL)
    }

    @Test
    func saveSettings_successWithCDOC2AndUseKeyTransferFalse() async throws {
        await viewModel.initializeSettings()

        viewModel.encryptionCdocOption = .cdoc2
        viewModel.useKeyTransfer = false
        viewModel.serverId = .manualSetting

        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )
        viewModel.serverInfo = testServerInfo

        await viewModel.saveSettings()

        #expect(mockDataStore.setEncryptionCdocOptionCallCount == 1)
        #expect(mockDataStore.setEncryptionUseKeyTransferCallCount == 1)
        #expect(mockDataStore.setEncryptionServerIdCallCount == 1)
        #expect(mockDataStore.setEncryptionServerInfoCallCount == 1)

        #expect(viewModel.encryptionCdocOption == .cdoc2)
        #expect(viewModel.useKeyTransfer == false)
        #expect(viewModel.serverId == .defaultSetting)
        #expect(viewModel.serverInfo.uuid != testServerInfo.uuid)
        #expect(viewModel.serverInfo.fetchURL != testServerInfo.fetchURL)
        #expect(viewModel.serverInfo.postURL != testServerInfo.postURL)
    }

    @Test
    func saveSettings_successWithCDOC2AndUseKeyTransferTrueAndServerIdDefault() async throws {
        await viewModel.initializeSettings()

        viewModel.encryptionCdocOption = .cdoc2
        viewModel.useKeyTransfer = true
        viewModel.serverId = .defaultSetting

        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )
        viewModel.serverInfo = testServerInfo

        await viewModel.saveSettings()

        #expect(mockDataStore.setEncryptionCdocOptionCallCount == 1)
        #expect(mockDataStore.setEncryptionUseKeyTransferCallCount == 1)
        #expect(mockDataStore.setEncryptionServerIdCallCount == 1)
        #expect(mockDataStore.setEncryptionServerInfoCallCount == 1)

        #expect(viewModel.encryptionCdocOption == .cdoc2)
        #expect(viewModel.useKeyTransfer == true)
        #expect(viewModel.serverId == .defaultSetting)
        #expect(viewModel.serverInfo.uuid != testServerInfo.uuid)
        #expect(viewModel.serverInfo.fetchURL != testServerInfo.fetchURL)
        #expect(viewModel.serverInfo.postURL != testServerInfo.postURL)
    }

    @Test
    func saveSettings_successWithCDOC2AllManual() async throws {
        await viewModel.initializeSettings()

        viewModel.encryptionCdocOption = .cdoc2
        viewModel.useKeyTransfer = true
        viewModel.serverId = .manualSetting

        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )
        viewModel.serverInfo = testServerInfo

        await viewModel.saveSettings()

        #expect(mockDataStore.setEncryptionCdocOptionCallCount == 1)
        #expect(mockDataStore.setEncryptionUseKeyTransferCallCount == 1)
        #expect(mockDataStore.setEncryptionServerIdCallCount == 1)
        #expect(mockDataStore.setEncryptionServerInfoCallCount == 1)

        #expect(viewModel.encryptionCdocOption == .cdoc2)
        #expect(viewModel.useKeyTransfer == true)
        #expect(viewModel.serverId == .manualSetting)
        #expect(viewModel.serverInfo.uuid == testServerInfo.uuid)
        #expect(viewModel.serverInfo.fetchURL == testServerInfo.fetchURL)
        #expect(viewModel.serverInfo.postURL == testServerInfo.postURL)
    }

    // MARK: - Cert info getter tests

    @Test
    func getSiVaCertIssuer_success() async throws {
        guard let certData = TestCertificateUtil.getSampleCertificateWithHeaders() else {
            Issue.record("Expected to have a valid certificate data object")
            return
        }

        viewModel.certData = certData
        _ = viewModel.getCertIssuer()
        #expect(mockCertificateUtil.getSubjectAttributeCallCount == 1)
    }

    @Test
    func getSiVaCertIssuer_returnsEmptyStringWithNoCert() async throws {
        let issuer = viewModel.getCertIssuer()
        #expect(issuer == "")
    }

    @Test
    func getSiVaCertNotValidAfter_success() async throws {
        guard let certData = TestCertificateUtil.getSampleCertificateWithHeaders() else {
            Issue.record("Expected to have a valid certificate data object")
            return
        }

        viewModel.certData = certData
        _ = viewModel.getCertNotValidAfter(expiredLabel: "Expired")
        #expect(mockCertificateUtil.getNotValidAfterWithExpiredLabelCallCount == 1)
    }

    @Test
    func getSiVaCertNotValidAfter_returnsEmptyStringWithNoCert() async throws {
        let label = viewModel.getCertNotValidAfter(expiredLabel: "Expired")
        #expect(label == "")
    }

    // MARK: - Import Cert tests

    @Test
    func importSiVaCert_success() async throws {
        let certURL = TestCertificateUtil.createSampleCertFile()
        defer {
            try? FileManager.default.removeItem(at: certURL)
        }

        guard let certData = TestCertificateUtil.getSampleCertificateWithHeaders() else {
            Issue.record("Expected to have a valid certificate data object")
            return
        }
        mockAdvancedSettingsRepository.importCertificateHandler = { _, _, _ in
            return certData
        }

        await viewModel.importCert(from: certURL)

        #expect(mockAdvancedSettingsRepository.importCertificateCallCount == 1)
    }
}
