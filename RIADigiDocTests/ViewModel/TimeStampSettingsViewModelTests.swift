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
import CommonsLibMocks
import CommonsTestShared
import ConfigLib
import ConfigLibMocks
import Foundation
import Testing

@MainActor
final class TimeStampSettingsViewModelTests {
    private let viewModel: TimeStampSettingsViewModel!

    private let mockDataStore: DataStoreProtocolMock!
    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock!
    private let mockFileManager: FileManagerProtocolMock!
    private let mockAdvancedSettingsRepository: AdvancedSettingsRepositoryProtocolMock!
    private let mockCertificateUtil: CertificateUtilProtocolMock!

    let mockConfigProvider: ConfigurationProvider!

    init() async throws {
        mockDataStore = DataStoreProtocolMock()
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockAdvancedSettingsRepository = AdvancedSettingsRepositoryProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()

        mockDataStore.getTSAUrlHandler = {
            return "http://default.url"
        }
        mockDataStore.getTSAUrlOptionHandler = {
            return .defaultSetting
        }

        mockConfigProvider = try TestConfigurationProvider.mockConfigurationProvider()
        TestConfigurationSetup.configureMocks(
            configurationRepository: mockConfigurationRepository,
            configProvider: mockConfigProvider
        )

        viewModel = TimeStampSettingsViewModel(
            configurationRepository: mockConfigurationRepository,
            dataStore: mockDataStore,
            fileManager: mockFileManager,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            certificateUtil: mockCertificateUtil
        )
    }

    // MARK: - init tests
    @Test
    func init_successWithEmptyUrl() async throws {
        mockDataStore.getTSAUrlHandler = {
            return ""
        }

        let testViewModel = TimeStampSettingsViewModel(
            configurationRepository: mockConfigurationRepository,
            dataStore: mockDataStore,
            fileManager: mockFileManager,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            certificateUtil: mockCertificateUtil
        )

        await testViewModel.initializeSettings()

        #expect(!testViewModel.tsaUrl.isEmpty)
    }

    // MARK: - saveSettings tests

    @Test
    func saveSettings_successWithDefaultSetting() async throws {
        viewModel.selectedOption = .defaultSetting
        let testURL = "some.url"
        viewModel.tsaUrl = testURL

        await viewModel.saveSettings()

        #expect(mockDataStore.setTSAUrlCallCount == 1)
        #expect(mockDataStore.setTSAUrlOptionCallCount == 1)

        #expect(viewModel.tsaUrl != testURL)
    }

    @Test
    func saveSettings_successWithManualSettingWithEmptyString() async throws {
        viewModel.selectedOption = .manualSetting
        let testURL = ""
        viewModel.tsaUrl = testURL
        await viewModel.observeConfigurationUpdates()

        await viewModel.saveSettings()

        #expect(mockDataStore.setTSAUrlCallCount == 1)
        #expect(mockDataStore.setTSAUrlOptionCallCount == 1)

        #expect(viewModel.tsaUrl != testURL)
    }

    @Test
    func saveSettings_successWithManualSettingWithValidURL() async throws {
        viewModel.selectedOption = .manualSetting
        let testURL = "http://valid.url.ee"
        viewModel.tsaUrl = testURL

        await viewModel.saveSettings()

        #expect(mockDataStore.setTSAUrlCallCount == 1)
        #expect(mockDataStore.setTSAUrlOptionCallCount == 1)

        #expect(viewModel.tsaUrl == testURL)
    }

    // MARK: - Cert info getter tests

    @Test
    func getTSACertIssuer_success() async throws {
        guard let certData = TestCertificateUtil.getSampleCertificateWithHeaders() else {
            Issue.record("Expected to have a valid certificate data object")
            return
        }

        viewModel.tsaCertData = certData
        _ = viewModel.getTSACertIssuer()
        #expect(mockCertificateUtil.getSubjectAttributeCallCount == 1)
    }

    @Test
    func getTSACertIssuer_returnsEmptyStringWithNoCert() async throws {
        let issuer = viewModel.getTSACertIssuer()
        #expect(issuer == "")
    }

    @Test
    func getTSACertNotValidAfter_success() async throws {
        guard let certData = TestCertificateUtil.getSampleCertificateWithHeaders() else {
            Issue.record("Expected to have a valid certificate data object")
            return
        }

        viewModel.tsaCertData = certData
        _ = viewModel.getTSACertNotValidAfter(expiredLabel: "Expired")
        #expect(mockCertificateUtil.getNotValidAfterWithExpiredLabelCallCount == 1)
    }

    @Test
    func getTSACertNotValidAfter_returnsEmptyStringWithNoCert() async throws {
        let label = viewModel.getTSACertNotValidAfter(expiredLabel: "Expired")
        #expect(label == "")
    }

    // MARK: - importTSACert test

    @Test
    func importTSACert_success() async throws {
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

        await viewModel.importTSACert(from: certURL)

        #expect(mockAdvancedSettingsRepository.importCertificateCallCount == 1)
    }
}
