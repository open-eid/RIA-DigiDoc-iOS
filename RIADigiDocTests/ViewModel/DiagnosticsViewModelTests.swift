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
import LibdigidocLibSwift
import LibdigidocLibSwiftMocks
import OSLog
import Testing
import UtilsLib
import UtilsLibMocks

@MainActor
final class DiagnosticsViewModelTests {
    private let viewModel: DiagnosticsViewModel!

    private let mockContainerWrapper: ContainerWrapperProtocolMock
    private let mockFileManager: FileManagerProtocolMock
    private let mockConfigurationLoader: ConfigurationLoaderProtocolMock
    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock
    private let mockTSLUtil: TSLUtilProtocolMock
    private let mockDataStore: DataStoreProtocolMock
    private let mockProxyUtil: ProxyUtilProtocolMock

    let mockConfigProvider: ConfigurationProvider?

    init() async throws {
        mockContainerWrapper = ContainerWrapperProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockConfigurationLoader = ConfigurationLoaderProtocolMock()
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockTSLUtil = TSLUtilProtocolMock()
        mockDataStore = DataStoreProtocolMock()
        mockProxyUtil = ProxyUtilProtocolMock()

        mockConfigProvider = try TestConfigurationProvider.mockConfigurationProvider()
        TestConfigurationSetup.configureMocks(
            configurationRepository: mockConfigurationRepository,
            configProvider: mockConfigProvider
        )

        mockProxyUtil.getProxyInfoHandler = { ProxyInfo() }

        viewModel = DiagnosticsViewModel(
            containerWrapper: mockContainerWrapper,
            fileManager: mockFileManager,
            configurationLoader: mockConfigurationLoader,
            configurationRepository: mockConfigurationRepository,
            tslUtil: mockTSLUtil,
            dataStore: mockDataStore,
            proxyUtil: mockProxyUtil
        )
    }

    private static func mockAsyncStream(
        configProvider: ConfigurationProvider
    ) -> AsyncThrowingStream<ConfigurationProvider?, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(configProvider)
            continuation.finish()
        }
    }

    // MARK: - Get Configuration Data Tests

    @Test
    func getConfigurationData_success() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp/test-schema-dir")
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        await viewModel.observeConfigurationUpdates()

        mockFileManager.contentsOfDirectoryAtHandler = { url, _, _ in
            let xmlFile = url.appending(path: "test1.xml")
            let txtFile = url.appending(path: "test1.txt")
            return [xmlFile, txtFile]
        }

        mockTSLUtil.readSequenceNumberHandler = { _ in
            return 45
        }

        mockDataStore.getRelyingPartyUUIDHandler = {
            return Constants.Signing.RelyingPartyUUID
        }

        await viewModel.getConfigurationData(
            configuration: mockConfigProvider,
            tslSchemaDirectory: testDirectory
        )

        await checkVersionSection()
        await checkOsSection()
        await checkUrlSection()
        await checkCdoc2Section()
        await checkTslSection()
        await checkCentralConfigurationSection()
    }

    private func setupLocalizedHandler(for mockLanguageSettings: LanguageSettingsProtocolMock) {
        mockLanguageSettings.localizedHandler = { key, _ in
            switch key {
            case "Main diagnostics operating system ios": return "iOS:"
            case "Main diagnostics configuration last check date": return "LAST CHECK"
            case "Main diagnostics configuration update date": return "UPDATE DATE"
            default: return key
            }
        }
    }

    private func checkVersionSection() async {
        #expect(!viewModel.versionSectionContent.isEmpty)
    }

    private func checkOsSection() async {
        #expect(!viewModel.osSectionContent.content.isEmpty)
    }

    private func checkUrlSection() async {
        #expect(viewModel.urlSectionContent == [
            "CONFIG_URL: https://someUrl.abc",
            "TSL_URL: https://tsl.someUrl.abc",
            "SIVA_URL: https://siva.someUrl.abc",
            "TSA_URL: https://tsa.someUrl.abc",
            "LDAP_PERSON_URL: https://ldap-person.someUrl.abc",
            "LDAP_CORP_URL: https://ldap-corp.someUrl.abc",
            "MID_PROXY_URL: https://midrest.someUrl.abc",
            "MID_SK_URL: https://midskrest.someUrl.abc",
            "SIDV2_PROXY_URL: https://sidv2.someUrl.abc",
            "SIDV2_SK_URL: https://sidv2skrest.someUrl.abc",
            "RPUUID: 00000000-0000-0000-0000-000000000000"
        ])
    }

    private func checkCdoc2Section() async {
        #expect(viewModel.cdoc2SectionContent == [
            "CDOC2-DEFAULT: false",
            "CDOC2-USE-KEYSERVER: false",
            "CDOC2-DEFAULT-KEYSERVER: https://cdoc2DefaultKeyserver.someUrl.abc"
        ])
    }

    private func checkTslSection() async {
        #expect(viewModel.tslSectionContent == ["test1.xml (45)"])
    }

    private func checkCentralConfigurationSection(hasDate: Bool = true) async {
        let date = !hasDate ? "-" : "02.09.2025 15:22:28"

        let centralConfigurationSectionContent = viewModel.centralConfigurationSectionContent
        let configurationSectionContent = centralConfigurationSectionContent.map {
            "\($0.key): \($0.content)"
        }
        let expected = [
            "DATE: 1970-01-01",
            "SERIAL: 1",
            "URL: https://someUrl.abc",
            "VERSION: 1",
            "Main diagnostics configuration update date: \(date)",
            "Main diagnostics configuration last check date: \(date)"
        ]

        #expect(expected == configurationSectionContent)

    }

    @Test
    func getConfigurationData_doesNotThrowWhenCouldNotListTslDirectory() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp/test-schema-dir")
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            await self.viewModel.getConfigurationData(
                configuration: mockConfigProvider,
                tslSchemaDirectory: testDirectory
            )
        }

        #expect(viewModel.tslSectionContent == [""])
    }

    @Test
    func getConfigurationData_doesNotThrowWhenTslFilesReadSequenceNumberFails() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp/test-schema-dir")
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        mockFileManager.contentsOfDirectoryAtHandler = { url, _, _ in
            let xmlFile = url.appending(path: "test1.xml")
            let txtFile = url.appending(path: "test1.txt")
            return [xmlFile, txtFile]
        }

        mockTSLUtil.readSequenceNumberHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        await #expect(throws: Never.self) {
            await self.viewModel.getConfigurationData(
                configuration: mockConfigProvider,
                tslSchemaDirectory: testDirectory
            )
        }

        #expect(viewModel.tslSectionContent == ["test1.xml"])
    }

    @Test
    func getConfigurationData_doesNotThrowWhenUpdateDateIsNil() async throws {
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        await viewModel.observeConfigurationUpdates()

        viewModel.configuration?.configurationUpdateDate = nil
        viewModel.configuration?.configurationLastUpdateCheckDate = nil

        await #expect(throws: Never.self) {
            await self.viewModel.getConfigurationData(configuration: mockConfigProvider)
        }

        await checkCentralConfigurationSection(hasDate: true)
    }

    @Test
    func getRpUuid_success() async {
        let rpUuid = Constants.Signing.RelyingPartyUUID
        mockDataStore.getRelyingPartyUUIDHandler = {
            return rpUuid
        }

        let uuid = await viewModel.getRpUuid()

        #expect(rpUuid == uuid)
    }

    // MARK: - Create Log File Tests

    @Test
    func createLogFile_success() async throws {
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        await viewModel.getConfigurationData(configuration: mockConfigProvider)

        let tempDirectoryURL = TestFileUtil.getTemporaryDirectory(subfolder: "logfiles")
        try FileManager.default.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)

        mockFileManager.urlHandler = { _, _, _, _ in tempDirectoryURL }
        mockFileManager.fileExistsHandler = { _ in true }
        mockFileManager.copyItemHandler = { _, _ in }

        defer {
            try? FileManager.default.removeItem(at: tempDirectoryURL)
        }

        if let logFileUrl = await viewModel.createLogFile(
            languageSettings: mockLanguageSettings,
            directory: tempDirectoryURL
        ) {
            #expect(!logFileUrl.resolvedPath.isEmpty)
        }
    }

    @Test
    func createLogFile_returnsNilWhenDirectoryDoesNotExist() async throws {
        mockFileManager.fileExistsHandler = { _ in false }

        let mockLanguageSettings = LanguageSettingsProtocolMock()
        await viewModel.getConfigurationData(configuration: mockConfigProvider)

        let logFileUrl = await self.viewModel.createLogFile(
            languageSettings: mockLanguageSettings,
        )
        #expect(logFileUrl == nil)
    }

    // MARK: - Remove Log Files Directory Tests

    @Test
    func removeLogFilesDirectory_success() async throws {
        viewModel.removeLogFilesDirectory()
        #expect(mockFileManager.removeItemCallCount == 1)
    }

    @Test
    func removeLogFilesDirectory_doesNotThrowWhenFails() async throws {
        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        #expect(throws: Never.self) {
            self.viewModel.removeLogFilesDirectory()
        }
    }

    // MARK: - Update Configuration Tests

    @Test
    func updateConfiguration_success() async throws {
        let status = await viewModel.updateConfiguration()
        #expect(mockConfigurationLoader.loadCentralConfigurationCallCount == 1)
        #expect(status)
    }

    @Test
    func updateConfiguration_returnsFalseOnFailure() async throws {
        mockConfigurationLoader.loadCentralConfigurationHandler = { _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        await #expect(throws: Never.self) {
            let status = await viewModel.updateConfiguration()
            #expect(!status)
        }

        #expect(mockConfigurationLoader.loadCentralConfigurationCallCount == 1)

    }

    // MARK: - Observe Configuration Updates Tests
    @Test
    func observeConfigurationUpdates_doesNotThrowWhenStreamIsNil() async throws {
        mockConfigurationRepository.observeConfigurationUpdatesHandler = {
            return nil
        }

        await #expect(throws: Never.self) {
            await self.viewModel.observeConfigurationUpdates()
        }
    }
}
