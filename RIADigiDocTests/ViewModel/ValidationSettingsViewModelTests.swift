// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLibMocks
import CommonsTestShared
import ConfigLib
import ConfigLibMocks
import Foundation
import Testing

@MainActor
final class ValidationSettingsViewModelTests {
    private let viewModel: ValidationSettingsViewModel!

    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock!
    private let mockDataStore: DataStoreProtocolMock!
    private let mockFileManager: FileManagerProtocolMock!
    private let mockAdvancedSettingsRepository: AdvancedSettingsRepositoryProtocolMock!
    private let mockCertificateUtil: CertificateUtilProtocolMock!

    init() async throws {
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockDataStore = DataStoreProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockAdvancedSettingsRepository = AdvancedSettingsRepositoryProtocolMock()
        mockCertificateUtil = CertificateUtilProtocolMock()

        mockDataStore.getValidationServiceURLHandler = {
            return "http://default.url"
        }

        mockDataStore.getValidationServiceOptionHandler = {
            return .defaultSetting
        }

        mockConfigurationRepository.getConfigurationHandler = {
            try? TestConfigurationProvider.mockConfigurationProvider()
        }

        viewModel = ValidationSettingsViewModel(
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
        mockDataStore.getValidationServiceURLHandler = {
            return ""
        }

        mockConfigurationRepository.getConfigurationHandler = {
            do {
                return try TestConfigurationProvider.mockConfigurationProvider()
            } catch {
                print(error)
                return nil
            }
        }

        let testViewModel = ValidationSettingsViewModel(
            configurationRepository: mockConfigurationRepository,
            dataStore: mockDataStore,
            fileManager: mockFileManager,
            advancedSettingsRepository: mockAdvancedSettingsRepository,
            certificateUtil: mockCertificateUtil
        )

        await testViewModel.initializeSettings()

        #expect(!testViewModel.validationServiceUrl.isEmpty)
    }

    // MARK: - saveSettings tests

    @Test
    func saveSettings_successWithDefaultSetting() async throws {
        viewModel.selectedOption = .defaultSetting
        let testURL = "some.url"
        viewModel.validationServiceUrl = testURL

        await viewModel.saveSettings()

        #expect(mockDataStore.setValidationServiceOptionCallCount == 1)
        #expect(mockDataStore.setValidationServiceURLCallCount == 1)

        #expect(viewModel.validationServiceUrl != testURL)
    }

    @Test
    func saveSettings_successWithManualSettingWithEmptyString() async throws {
        viewModel.selectedOption = .manualSetting
        let testURL = ""
        viewModel.validationServiceUrl = testURL
        viewModel.configuration = try? TestConfigurationProvider.mockConfigurationProvider()

        await viewModel.saveSettings()

        #expect(mockDataStore.setValidationServiceOptionCallCount == 1)
        #expect(mockDataStore.setValidationServiceURLCallCount == 1)

        #expect(viewModel.validationServiceUrl != testURL)
    }

    @Test
    func saveSettings_successWithManualSettingWithValidURL() async throws {
        viewModel.selectedOption = .manualSetting
        let testURL = "http://valid.url.ee"
        viewModel.validationServiceUrl = testURL

        mockDataStore.getValidationServiceURLHandler = {
            return testURL
        }

        await viewModel.saveSettings()

        #expect(mockDataStore.setValidationServiceOptionCallCount == 1)
        #expect(mockDataStore.setValidationServiceURLCallCount == 1)

        #expect(viewModel.validationServiceUrl == testURL)
    }

    // MARK: - Cert info getter tests

    @Test
    func getSiVaCertIssuer_success() async throws {
        guard let certData = TestCertificateUtil.getSampleCertificateWithHeaders() else {
            Issue.record("Expected to have a valid certificate data object")
            return
        }

        viewModel.sivaCertData = certData
        _ = viewModel.getSiVaCertIssuer()
        #expect(mockCertificateUtil.getSubjectAttributeCallCount == 1)
    }

    @Test
    func getSiVaCertIssuer_returnsEmptyStringWithNoCert() async throws {
        let issuer = viewModel.getSiVaCertIssuer()
        #expect(issuer == "")
    }

    @Test
    func getSiVaCertNotValidAfter_success() async throws {
        guard let certData = TestCertificateUtil.getSampleCertificateWithHeaders() else {
            Issue.record("Expected to have a valid certificate data object")
            return
        }

        viewModel.sivaCertData = certData
        _ = viewModel.getSiVaCertNotValidAfter(expiredLabel: "Expired")
        #expect(mockCertificateUtil.getNotValidAfterWithExpiredLabelCallCount == 1)
    }

    @Test
    func getSiVaCertNotValidAfter_returnsEmptyStringWithNoCert() async throws {
        let label = viewModel.getSiVaCertNotValidAfter(expiredLabel: "Expired")
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

        await viewModel.importSiVaCert(from: certURL)

        #expect(mockAdvancedSettingsRepository.importCertificateCallCount == 1)
    }
}
