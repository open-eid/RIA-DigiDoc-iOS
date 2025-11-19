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
import LibdigidocLibSwift
import OSLog
import UtilsLib

@MainActor
class DiagnosticsViewModel: DiagnosticsViewModelProtocol, ObservableObject {
    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc", category: "DiagnosticsViewModel")

    @Published var configuration: ConfigurationProvider?

    // MARK: - section content
    @Published var versionSectionContent: String = ""
    @Published var osSectionContent: (key: String, content: String) = (key: "", content: "")
    @Published var libdigidocVersion: String = ""
    @Published var urlSectionContent: [String] = [""]
    @Published var cdoc2SectionContent: [String] = [""]
    @Published var tslSectionContent: [String] = [""]
    @Published var centralConfigurationSectionContent: [(key: String, content: String)] = [(key: "", content: "")]

    // MARK: - dependencies
    private let containerWrapper: ContainerWrapperProtocol
    private let fileManager: FileManagerProtocol
    private let configurationLoader: ConfigurationLoaderProtocol
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let tslUtil: TSLUtilProtocol
    private let dataStore: DataStoreProtocol
    private let proxyUtil: ProxyUtilProtocol

    private var configurationObservationTask: Task<Void, Never>?

    init(
        containerWrapper: ContainerWrapperProtocol,
        fileManager: FileManagerProtocol,
        configurationLoader: ConfigurationLoaderProtocol,
        configurationRepository: ConfigurationRepositoryProtocol,
        tslUtil: TSLUtilProtocol,
        dataStore: DataStoreProtocol,
        proxyUtil: ProxyUtilProtocol
    ) {
        self.containerWrapper = containerWrapper
        self.fileManager = fileManager
        self.configurationLoader = configurationLoader
        self.configurationRepository = configurationRepository
        self.tslUtil = tslUtil
        self.dataStore = dataStore
        self.proxyUtil = proxyUtil

        configurationObservationTask = Task {
            await observeConfigurationUpdates()
        }

        Task {
            await loadLibdigidocVersion()

            for await config in $configuration.values {
                if let config = config {
                    await getConfigurationData(configuration: config)
                }
            }
        }
    }

    public func removeObservers() async {
        configurationObservationTask?.cancel()
    }

    // MARK: - Fetching content

    func getConfigurationData(
        configuration: ConfigurationProvider?,
        tslSchemaDirectory: URL? = nil,
    ) async {
        getVersionContent()
        loadOsSectionContent()
        await loadUrlSectionContent(configuration: configuration)
        loadCdoc2SectionContent(configuration: configuration)
        loadTslSectionContent(schemaDirectory: tslSchemaDirectory)
        loadCentralConfigurationContent(configuration: configuration)
    }

    func getRpUuid() async -> String {
        await dataStore.getRelyingPartyUUID()
    }

    private func getVersionContent() {
        self.versionSectionContent =
        BundleUtil.getBundleShortVersionString() + "." + BundleUtil.getBundleVersion()
    }

    private func loadOsSectionContent() {
        self.osSectionContent = (key: "Main diagnostics operating system ios", content: SystemUtil.getOSVersion())
    }

    private func loadLibdigidocVersion() async {
        let libdigidocVersion = await containerWrapper.getVersion()

        self.libdigidocVersion = "libdigidocpp \(libdigidocVersion)"
    }

    private func loadUrlSectionContent(configuration: ConfigurationProvider?) async {
        guard let config = configuration else { return }

        let lines: [(label: String, value: String)] = await [
            ("CONFIG_URL", config.metaInf.url),
            ("TSL_URL", config.tslUrl.absoluteString),
            ("SIVA_URL", config.sivaUrl.absoluteString),
            ("TSA_URL", config.tsaUrl.absoluteString),
            ("LDAP_PERSON_URL", config.ldapPersonUrl.absoluteString),
            ("LDAP_CORP_URL", config.ldapCorpUrl.absoluteString),
            ("MID_PROXY_URL", config.midRestUrl.absoluteString),
            ("MID_SK_URL", config.midSkRestUrl.absoluteString),
            ("SIDV2_PROXY_URL", config.sidV2RestUrl.absoluteString),
            ("SIDV2_SK_URL", config.sidV2SkRestUrl.absoluteString),
            ("RPUUID", getRpUuid())
        ]

        self.urlSectionContent = lines.map { "\($0.label): \($0.value)" }
    }

    private func loadCdoc2SectionContent(configuration: ConfigurationProvider?) {
        guard let config = configuration else { return }

        let lines: [(label: String, value: String)] = [
            ("CDOC2-DEFAULT", String(config.cdoc2UseKeyserver)),
            ("CDOC2-USE-KEYSERVER", String(config.cdoc2UseKeyserver)),
            ("CDOC2-DEFAULT-KEYSERVER", config.cdoc2DefaultKeyserver)
        ]

        self.cdoc2SectionContent = lines.map { "\($0.label): \($0.value)" }
    }

    private func loadTslSectionContent(schemaDirectory: URL? = nil) {
        let directory = schemaDirectory ?? Directories.getLibraryDirectory(fileManager: fileManager)
        guard let schemaDirectory = directory else {
            DiagnosticsViewModel.logger.error("Unable to get the schema directory")
            return
        }

        do {
            let directoryFiles = try fileManager.contentsOfDirectory(
                at: schemaDirectory,
                includingPropertiesForKeys: [],
                options: [])

            var filesWithSequenceNumber: [String] = []

            for fileURL in directoryFiles {
                let fileName = fileURL.lastPathComponent
                guard fileName.hasSuffix(".xml") else { continue }

                do {
                    let sequenceNumber = try tslUtil.readSequenceNumber(from: fileURL)

                    filesWithSequenceNumber.append("\(fileName) (\(sequenceNumber))")
                } catch {
                    DiagnosticsViewModel.logger.error(
                        "Failed to parse \(fileURL): \(error.localizedDescription)")
                    filesWithSequenceNumber.append(fileName)
                }
            }

            self.tslSectionContent = filesWithSequenceNumber

        } catch {
            DiagnosticsViewModel.logger.error("Could not list TSL directory: \(error)")
        }
    }

    private func loadCentralConfigurationContent(configuration: ConfigurationProvider?) {
        guard let config = configuration else { return }

        let updateDateLabel = "Main diagnostics configuration update date"
        let lastCheckLabel = "Main diagnostics configuration last check date"

        let updateDate = formattedDateTimeString(config.configurationUpdateDate)
        let lastUpdateCheckDate = formattedDateTimeString(config.configurationLastUpdateCheckDate)

        let lines: [(label: String, value: String)] = [
            ("DATE", config.metaInf.date),
            ("SERIAL", String(config.metaInf.serial)),
            ("URL", config.metaInf.url),
            ("VERSION", String(config.metaInf.version)),
            (updateDateLabel, updateDate),
            (lastCheckLabel, lastUpdateCheckDate)
        ]

        centralConfigurationSectionContent = lines.map { (key: $0.label, content: $0.value) }
    }

    private func formattedDateTimeString(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let dateTime = DateUtil.getFormattedDateTime(
            date: date,
            isUTC: false,
        )
        return "\(dateTime.date) \(dateTime.time)"
    }

    // MARK: - Create Log File

    func createLogFile(languageSettings: LanguageSettingsProtocol, directory: URL? = nil) async -> URL? {
        let diagnosticsText = buildDiagnosticsText(languageSettings: languageSettings)
        do {

            let savedFilesDirectory = try directory ?? Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.Logs,
                fileManager: fileManager
            )
            let diagnosticsFileName = "ria_digidoc_\(self.versionSectionContent)_diagnostics.log"
            let fileURL = savedFilesDirectory.appendingPathComponent(diagnosticsFileName)

            try diagnosticsText.write(to: fileURL, atomically: true, encoding: .utf8)

            return fileURL
        } catch {
            DiagnosticsViewModel.logger.error(
                "Failed to write diagnostics file: \(error.localizedDescription)")
        }
        return nil
    }

    func removeLogFilesDirectory() {
        do {
            let directory = try Directories.getCacheDirectory(
                subfolder: CommonsLib.Constants.Folder.Logs,
                fileManager: fileManager
            )
            try fileManager.removeItem(at: directory)
            DiagnosticsViewModel.logger.debug("Saved Files directory removed")
        } catch {
            DiagnosticsViewModel.logger.error(
                "Unable to delete saved files directory: \(error.localizedDescription)")
        }
    }

    private func buildDiagnosticsText(languageSettings: LanguageSettingsProtocol) -> String {
        var lines: [String] = []

        lines.append(languageSettings.localized("Main diagnostics application version title"))
        lines.append(self.versionSectionContent)
        lines.append("")

        lines.append(languageSettings.localized("Main diagnostics operating system title"))
        lines.append("\(languageSettings.localized(osSectionContent.key)) \(osSectionContent.content)")
        lines.append("")

        lines.append(languageSettings.localized("Main diagnostics libraries title"))
        lines.append(self.libdigidocVersion)
        lines.append("")

        lines.append(languageSettings.localized("Main diagnostics urls title"))
        lines.append(contentsOf: self.urlSectionContent)
        lines.append("")

        lines.append(languageSettings.localized("Main diagnostics cdoc2 title"))
        lines.append(contentsOf: self.cdoc2SectionContent)
        lines.append("")

        lines.append(languageSettings.localized("Main diagnostics tsl cache title"))
        lines.append(contentsOf: self.tslSectionContent)
        lines.append("")

        lines.append(languageSettings.localized("Main diagnostics central configuration title"))
        lines.append(contentsOf: self.centralConfigurationSectionContent.map {
            "\(languageSettings.localized($0.key)): \($0.content)"
        })

        return lines.joined(separator: "\n")
    }

    // MARK: - Update configuration

    func updateConfiguration() async -> Bool {
        do {
            let configDirectory = try Directories.getCacheDirectory(
                fileManager: fileManager
            ).appendingPathComponent(
                CommonsLib.Constants.Configuration.CacheConfigFolder
            )
            let proxyInfo = await proxyUtil.getProxyInfo()
            try await configurationLoader.loadCentralConfiguration(
                cacheDir: configDirectory,
                proxyInfo: proxyInfo
            )
            return true
        } catch {
            DiagnosticsViewModel.logger.error("Unable to update configuration: \(error)")
            return false
        }
    }

    // MARK: - Observer

    public func observeConfigurationUpdates() async {
        guard !Task.isCancelled else {
            return
        }

        guard let configStream = await configurationRepository.observeConfigurationUpdates(
        ) else {
            DiagnosticsViewModel.logger.error("Unable to get configuration updates stream")
            return
        }

        do {
            for try await config in configStream {
                await MainActor.run {
                    configuration = config
                }
            }
        } catch {
            DiagnosticsViewModel.logger.error("Unable to get configuration from stream")
        }
    }
}
