/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
    private let mockCryptoSetup: CryptoSetupProtocolMock!

    let mockConfigProvider: ConfigurationProvider!

    init() async throws {
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockDataStore = DataStoreProtocolMock()
        mockAdvancedSettingsRepository = AdvancedSettingsRepositoryProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()
        mockCryptoSetup = CryptoSetupProtocolMock()

        mockDataStore.getEncryptionCdocOptionHandler = { _ in
            return .cdoc1
        }

        mockDataStore.getEncryptionUseKeyTransferHandler = { _ in
            return false
        }

        mockDataStore.getEncryptionServerIdHandler = { _ in
            return Constants.CryptoDefaultValues.encryptionServerInfoUUID
        }

        mockDataStore.getEncryptionServerInfoHandler = { _ in
            return EncryptionServerInfo()
        }

        mockConfigProvider = try TestConfigurationProvider.mockConfigurationProvider()
        TestConfigurationSetup.configureMocks(
            configurationRepository: mockConfigurationRepository,
            configProvider: mockConfigProvider
        )

        mockDataStore.getCentralCDOC2ConfHandler = { _, _ in
            return EncryptionServerInfo()
        }

        viewModel = EncryptionSettingsViewModel(
            configurationRepository: mockConfigurationRepository,
            dataStore: mockDataStore,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            certificateUtil: mockCertificateUtil,
            cryptoSetup: mockCryptoSetup
        )
    }

    // MARK: - init tests

    @Test
    func init_successManualServerId() async throws {
        mockDataStore.getEncryptionServerIdHandler = { _ in
            return "00000000-0000-0000-0000-100000000000"
        }

        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )
        mockDataStore.getEncryptionServerInfoHandler = { _ in
            return testServerInfo
        }

        let testViewModel = EncryptionSettingsViewModel(
            configurationRepository: mockConfigurationRepository,
            dataStore: mockDataStore,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            certificateUtil: mockCertificateUtil,
            cryptoSetup: mockCryptoSetup
        )

        mockDataStore.getCentralCDOC2ConfHandler = { _, _ in
            return testServerInfo
        }

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
        viewModel.serverId = "00000000-0000-0000-0000-100000000000"

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
        #expect(viewModel.serverId == Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        #expect(viewModel.serverInfo.uuid != testServerInfo.uuid)
        #expect(viewModel.serverInfo.fetchURL != testServerInfo.fetchURL)
        #expect(viewModel.serverInfo.postURL != testServerInfo.postURL)
    }

    @Test
    func saveSettings_successWithCDOC2AndUseKeyTransferFalse() async throws {
        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )

        let testServerInfo2 = EncryptionServerInfo(
            uuid: "testUUID2",
            fetchURL: "testFetchURL2",
            postURL: "testPostURL2"
        )

        mockDataStore.getCentralCDOC2ConfHandler = { _, _ in
            return testServerInfo
        }

        await viewModel.initializeSettings()

        viewModel.encryptionCdocOption = .cdoc2
        viewModel.useKeyTransfer = false
        viewModel.serverId = "00000000-0000-0000-0000-100000000000"

        viewModel.serverInfo = testServerInfo2

        await viewModel.saveSettings()

        #expect(mockDataStore.setEncryptionCdocOptionCallCount == 1)
        #expect(mockDataStore.setEncryptionUseKeyTransferCallCount == 1)
        #expect(mockDataStore.setEncryptionServerIdCallCount == 1)
        #expect(mockDataStore.setEncryptionServerInfoCallCount == 1)

        #expect(viewModel.encryptionCdocOption == .cdoc2)
        #expect(viewModel.useKeyTransfer == false)
        #expect(viewModel.serverId == Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        #expect(viewModel.serverInfo.uuid != testServerInfo2.uuid)
        #expect(viewModel.serverInfo.fetchURL != testServerInfo2.fetchURL)
        #expect(viewModel.serverInfo.postURL != testServerInfo2.postURL)
    }

    @Test
    func saveSettings_successWithCDOC2AndUseKeyTransferTrueAndServerIdDefault() async throws {
        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )

        let testServerInfo2 = EncryptionServerInfo(
            uuid: "testUUID2",
            fetchURL: "testFetchURL2",
            postURL: "testPostURL2"
        )

        mockDataStore.getCentralCDOC2ConfHandler = { _, _ in
            return testServerInfo
        }

        await viewModel.initializeSettings()

        viewModel.encryptionCdocOption = .cdoc2
        viewModel.useKeyTransfer = true
        viewModel.serverId = Constants.CryptoDefaultValues.encryptionServerInfoUUID
        viewModel.serverInfo = testServerInfo2

        await viewModel.saveSettings()

        #expect(mockDataStore.setEncryptionCdocOptionCallCount == 1)
        #expect(mockDataStore.setEncryptionUseKeyTransferCallCount == 1)
        #expect(mockDataStore.setEncryptionServerIdCallCount == 1)
        #expect(mockDataStore.setEncryptionServerInfoCallCount == 1)

        #expect(viewModel.encryptionCdocOption == .cdoc2)
        #expect(viewModel.useKeyTransfer == true)
        #expect(viewModel.serverId == Constants.CryptoDefaultValues.encryptionServerInfoUUID)
        #expect(viewModel.serverInfo.uuid != testServerInfo2.uuid)
        #expect(viewModel.serverInfo.fetchURL != testServerInfo2.fetchURL)
        #expect(viewModel.serverInfo.postURL != testServerInfo2.postURL)
    }

    @Test
    func saveSettings_successWithCDOC2AllManual() async throws {
        let testServerInfo = EncryptionServerInfo(
            uuid: "testUUID",
            fetchURL: "testFetchURL",
            postURL: "testPostURL"
        )
        mockDataStore.getCentralCDOC2ConfHandler = { _, _ in
            return testServerInfo
        }

        await viewModel.initializeSettings()

        viewModel.encryptionCdocOption = .cdoc2
        viewModel.useKeyTransfer = true
        viewModel.serverId = "00000000-0000-0000-0000-100000000000"

        viewModel.serverInfo = testServerInfo

        await viewModel.saveSettings()

        #expect(mockDataStore.setEncryptionCdocOptionCallCount == 1)
        #expect(mockDataStore.setEncryptionUseKeyTransferCallCount == 1)
        #expect(mockDataStore.setEncryptionServerIdCallCount == 1)
        #expect(mockDataStore.setEncryptionServerInfoCallCount == 1)

        #expect(viewModel.encryptionCdocOption == .cdoc2)
        #expect(viewModel.useKeyTransfer == true)
        #expect(viewModel.serverId == "00000000-0000-0000-0000-100000000000")
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
        let certURL = try TestCertificateUtil.createSampleCertFile()
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
