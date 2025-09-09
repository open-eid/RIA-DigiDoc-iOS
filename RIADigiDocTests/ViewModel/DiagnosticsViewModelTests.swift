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

    private let mockContainerWrapper: ContainerWrapperProtocolMock!
    private let mockFileManager: FileManagerProtocolMock!
    private let mockConfigurationLoader: ConfigurationLoaderProtocolMock!
    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock!
    private let mockTSLUtil: TSLUtilProtocolMock!

    let mockConfigProvider: ConfigurationProvider!

    init() async throws {
        mockContainerWrapper = ContainerWrapperProtocolMock()
        mockFileManager = FileManagerProtocolMock()
        mockConfigurationLoader = ConfigurationLoaderProtocolMock()
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockTSLUtil = TSLUtilProtocolMock()

        mockConfigProvider = TestConfigurationProvider.mockConfigurationProvider()

        mockConfigurationRepository.observeConfigurationUpdatesHandler = { [mockConfigProvider] in
            guard let mockConfig = mockConfigProvider else {
                return AsyncThrowingStream { continuation in
                    continuation.yield(nil)
                    continuation.finish(throwing: DecodingError.valueNotFound(
                        Int.self,
                        DecodingError.Context(
                            codingPath: [],
                            debugDescription: "Expected a non-nil mockConfigProvider value"
                        )
                    )
                    )
                }
            }

            return await DiagnosticsViewModelTests
                .mockAsyncStream(configProvider: mockConfig)
        }

        mockConfigurationRepository.getCentralConfigurationUpdatesHandler = { [mockConfigProvider] _ async throws in
            guard let mockConfig = mockConfigProvider else {
                return AsyncThrowingStream { continuation in
                    continuation.yield(nil)
                    continuation.finish(throwing: DecodingError.valueNotFound(
                        Int.self,
                        DecodingError.Context(
                            codingPath: [],
                            debugDescription: "Expected a non-nil mockConfigProvider value"
                        )
                    )
                    )
                }
            }

            return await DiagnosticsViewModelTests
                .mockAsyncStream(configProvider: mockConfig)
        }

        viewModel = DiagnosticsViewModel(
            containerWrapper: mockContainerWrapper,
            fileManager: mockFileManager,
            configurationLoader: mockConfigurationLoader,
            configurationRepository: mockConfigurationRepository,
            tslUtil: mockTSLUtil,
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

    // MARK: - Fetch Content Tests

    @Test
    func fetchContent_success() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp/test-schema-dir")
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        try await viewModel.observeConfigurationUpdates()

        mockFileManager.contentsOfDirectoryAtHandler = { url, _, _ in
            let xmlFile = url.appendingPathComponent("test1.xml")
            let txtFile = url.appendingPathComponent("test1.txt")
            return [xmlFile, txtFile]
        }
        mockTSLUtil.readSequenceNumberHandler = { _ in
            return 45
        }

        viewModel.fetchContent(languageSettings: mockLanguageSettings, tslSchemaDirectory: testDirectory)

        await checkVersionSection()
        await checkOsSection()
        await checkUrlSection()
        await checkCdoc2Section()
        await checkTslSection()
        await checkCentralConfigurationSection()
    }

    private func setupLocalizedHandler(for mockLanguageSettings: LanguageSettingsProtocolMock) {
        mockLanguageSettings.localizedHandler = { key in
            switch key {
            case "Main diagnostics operating system ios %@": return "iOS: %@"
            case "Main diagnostics configuration last check date": return "LAST CHECK"
            case "Main diagnostics configuration update date": return "UPDATE DATE"
            default: return key
            }
        }
    }

    private func checkVersionSection() async {
        for try await versionSectionContent in viewModel.$versionSectionContent.values {
            #expect(!versionSectionContent.isEmpty)
            break
        }
    }

    private func checkOsSection() async {
        for try await osSectionContent in viewModel.$osSectionContent.values {
            #expect(!osSectionContent.isEmpty)
            break
        }
    }

    private func checkUrlSection() async {
        for try await urlSectionContent in viewModel.$urlSectionContent.values {
            #expect(urlSectionContent == [
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
                "RPUUID: -"
            ])
            break
        }
    }

    private func checkCdoc2Section() async {
        for try await cdoc2SectionContent in viewModel.$cdoc2SectionContent.values {
            #expect(cdoc2SectionContent == [
                "CDOC2-DEFAULT: false",
                "CDOC2-USE-KEYSERVER: false",
                "CDOC2-DEFAULT-KEYSERVER: https://cdoc2DefaultKeyserver.someUrl.abc"
            ])
            break
        }
    }

    private func checkTslSection() async {
        for try await tslSectionContent in viewModel.$tslSectionContent.values {
            #expect(tslSectionContent == ["test1.xml (45)"])
            break
        }
    }

    private func checkCentralConfigurationSection(dateIsNil: Bool = false) async {
        let date = dateIsNil ? "-" : "02.09.2025 15:22:28"

        for try await centralConfigurationSectionContent in viewModel.$centralConfigurationSectionContent.values {
            #expect(centralConfigurationSectionContent == [
                "DATE: 1970-01-01",
                "SERIAL: 1",
                "URL: https://someUrl.abc",
                "VERSION: 1",
                "UPDATE DATE: \(date)",
                "LAST CHECK: \(date)"
            ])
            break
        }
    }

    @Test
    func fetchContent_doesNotThrowWhenCouldNotListTslDirectory() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp/test-schema-dir")
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        mockFileManager.contentsOfDirectoryAtHandler = { _, _, _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        #expect(throws: Never.self) {
            self.viewModel.fetchContent(languageSettings: mockLanguageSettings, tslSchemaDirectory: testDirectory)
        }

        for try await tslSectionContent in viewModel.$tslSectionContent.values {
            #expect(tslSectionContent == [""])
            break
        }
    }

    @Test
    func fetchContent_doesNotThrowWhenTslFilesReadSequenceNumberFails() async throws {
        let testDirectory = URL(fileURLWithPath: "/tmp/test-schema-dir")
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        mockFileManager.contentsOfDirectoryAtHandler = { url, _, _ in
            let xmlFile = url.appendingPathComponent("test1.xml")
            let txtFile = url.appendingPathComponent("test1.txt")
            return [xmlFile, txtFile]
        }

        mockTSLUtil.readSequenceNumberHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }

        #expect(throws: Never.self) {
            self.viewModel.fetchContent(languageSettings: mockLanguageSettings, tslSchemaDirectory: testDirectory)
        }

        for try await tslSectionContent in viewModel.$tslSectionContent.values {
            #expect(tslSectionContent == ["test1.xml"])
            break
        }
    }

    @Test func fetchContent_doesNotThrowWhenUpdateDateIsNil() async throws {
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        setupLocalizedHandler(for: mockLanguageSettings)

        try await viewModel.observeConfigurationUpdates()

        viewModel.configuration?.configurationUpdateDate = nil
        viewModel.configuration?.configurationLastUpdateCheckDate = nil

        #expect(throws: Never.self) {
            self.viewModel.fetchContent(languageSettings: mockLanguageSettings)
        }

        await checkCentralConfigurationSection(dateIsNil: true)
    }

    // MARK: - Create Log File Tests

    @Test func createLogFile_success() async throws {
        let mockLanguageSettings = LanguageSettingsProtocolMock()
        viewModel.fetchContent(languageSettings: mockLanguageSettings)

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
            #expect(!logFileUrl.path.isEmpty)
        }
    }

    @Test func createLogFile_returnsNilWhenDirectoryDoesNotExist() async throws {
        mockFileManager.fileExistsHandler = { _ in false }

        let mockLanguageSettings = LanguageSettingsProtocolMock()
        viewModel.fetchContent(languageSettings: mockLanguageSettings)

        let logFileUrl = await self.viewModel.createLogFile(
            languageSettings: mockLanguageSettings,
        )
        #expect(logFileUrl == nil)
    }

    // MARK: - Remove Log Files Directory Tests

    @Test func removeLogFilesDirectory_success() async throws {
        viewModel.removeLogFilesDirectory()
        #expect(mockFileManager.removeItemCallCount == 1)
    }

    @Test func removeLogFilesDirectory_doesNotThrowWhenFails() async throws {
        mockFileManager.removeItemHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        #expect(throws: Never.self) {
            self.viewModel.removeLogFilesDirectory()
        }
    }

    // MARK: - Update Configuration Tests

    @Test func updateConfiguration_success() async throws {
        await viewModel.updateConfiguration()
        #expect(mockConfigurationLoader.loadCentralConfigurationCallCount == 1)
    }

    @Test func updateConfiguration_doesNotThrowOnFailure() async throws {
        mockConfigurationLoader.loadCentralConfigurationHandler = { _ in
            throw NSError(domain: "TestError", code: 1, userInfo: nil)
        }
        await #expect(throws: Never.self) {
            await self.viewModel.updateConfiguration()
        }

        #expect(mockConfigurationLoader.loadCentralConfigurationCallCount == 1)
    }

    // MARK: - Observe Configuration Updates Tests
    @Test func observeConfigurationUpdates_doesNotThrowWhenStreamIsNil() async throws {
        mockConfigurationRepository.observeConfigurationUpdatesHandler = {
            return nil
        }
        await #expect(throws: Never.self) {
            try await self.viewModel.observeConfigurationUpdates()
        }
    }
}
