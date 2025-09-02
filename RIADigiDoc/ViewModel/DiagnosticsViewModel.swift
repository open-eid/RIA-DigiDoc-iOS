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
    @Published var osSectionContent: String = ""
    @Published var libdigidocVersion: String = ""
    @Published var urlSectionContent: [String] = [""]
    @Published var cdoc2SectionContent: [String] = [""]
    @Published var tslSectionContent: [String] = [""]
    @Published var centralConfigurationSectionContent: [String] = [""]

    // MARK: - dependencies
    private let containerWrapper: ContainerWrapperProtocol
    private let fileManager: FileManagerProtocol
    private let configurationLoader: ConfigurationLoaderProtocol
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let tslUtil: TSLUtilProtocol

    init(
        containerWrapper: ContainerWrapperProtocol,
        fileManager: FileManagerProtocol,
        configurationLoader: ConfigurationLoaderProtocol,
        configurationRepository: ConfigurationRepositoryProtocol,
        tslUtil: TSLUtilProtocol
    ) {
        self.containerWrapper = containerWrapper
        self.fileManager = fileManager
        self.configurationLoader = configurationLoader
        self.configurationRepository = configurationRepository
        self.tslUtil = tslUtil

        Task {
            await fetchAsyncContent()
            try await observeConfigurationUpdates()
        }
    }

    // MARK: - Fetching content

    func fetchContent(
            languageSettings: LanguageSettingsProtocol,
            tslSchemaDirectory: URL? = nil
        ) {
        fetchVersionContent()
        fetchOsSectionContent(languageSettings: languageSettings)
        fetchUrlSectionContent()
        fetchCdoc2SectionContent()
        fetchTslSectionContent(schemaDirectory: tslSchemaDirectory)
        fetchCentralConfigurationContent(languageSettings: languageSettings)
    }

    func fetchAsyncContent() async {
        await fetchLibdigidocVersion()
    }

    private func fetchVersionContent() {
        self.versionSectionContent =
            BundleUtil.getBundleShortVersionString() + "." + BundleUtil.getBundleVersion()
    }

    private func fetchOsSectionContent(languageSettings: LanguageSettingsProtocol) {
        self.osSectionContent = String(
            format: languageSettings.localized("Main diagnostics operating system ios %@"),
            SystemUtil.getOSVersion()
        )
    }

    private func fetchLibdigidocVersion() async {
        let libdigidocVersion = await containerWrapper.getVersion()

        self.libdigidocVersion = "libdigidocpp \(libdigidocVersion)"
    }

    private func fetchUrlSectionContent() {
        guard let config = configuration else { return }

        let lines: [(label: String, value: String)] = [
            ("CONFIG_URL", config.metaInf.url),
            ("TSL_URL", config.tslUrl),
            ("SIVA_URL", config.sivaUrl),
            ("TSA_URL", config.tsaUrl),
            ("LDAP_PERSON_URL", config.ldapPersonUrl),
            ("LDAP_CORP_URL", config.ldapCorpUrl),
            ("MID_PROXY_URL", config.midRestUrl),
            ("MID_SK_URL", config.midSkRestUrl),
            ("SIDV2_PROXY_URL", config.sidV2RestUrl),
            ("SIDV2_SK_URL", config.sidV2SkRestUrl),
            ("RPUUID", "-")  // TODO: implement RPUUID
        ]

        self.urlSectionContent = lines.map { "\($0.label): \($0.value)" }
    }

    private func fetchCdoc2SectionContent() {
        guard let config = configuration else { return }

        let lines: [(label: String, value: String)] = [
            ("CDOC2-DEFAULT", String(config.cdoc2UseKeyserver)),
            ("CDOC2-USE-KEYSERVER", String(config.cdoc2UseKeyserver)),
            ("CDOC2-DEFAULT-KEYSERVER", config.cdoc2DefaultKeyserver)
        ]

        self.cdoc2SectionContent = lines.map { "\($0.label): \($0.value)" }
    }

    private func fetchTslSectionContent(schemaDirectory: URL? = nil) {
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

    private func fetchCentralConfigurationContent(languageSettings: LanguageSettingsProtocol) {
        guard let config = configuration else { return }

        let updateDateLabel = languageSettings.localized(
            "Main diagnostics configuration update date")
        let lastCheckLabel = languageSettings.localized(
            "Main diagnostics configuration last check date")

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

        centralConfigurationSectionContent = lines.map { "\($0.label): \($0.value)" }
    }

    private func formattedDateTimeString(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let dateTimeString = DateUtil.configurationDateFormatter.string(from: date)
        let dateTime = DateUtil.getFormattedDateTime(
            dateTimeString: dateTimeString,
            isUTC: false,
            inputDateFormat: "yyyy-MM-dd HH:mm:ss"
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
            let directory =
                try Directories.getCacheDirectory(
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
        lines.append(self.osSectionContent)
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
        lines.append(contentsOf: self.centralConfigurationSectionContent)

        return lines.joined(separator: "\n")
    }

    // MARK: - Update configuration

    func updateConfiguration() async {
        do {
            let configDirectory = try Directories.getCacheDirectory(
                fileManager: fileManager
            ).appendingPathComponent(
                CommonsLib.Constants.Configuration.CacheConfigFolder
            )
            try await configurationLoader.loadCentralConfiguration(cacheDir: configDirectory)
        } catch {
            DiagnosticsViewModel.logger.error("Unable to update configuration")
        }
    }

    // MARK: - Observer

    public func observeConfigurationUpdates() async throws {
        guard let configStream = await configurationRepository.observeConfigurationUpdates()
        else {
            DiagnosticsViewModel.logger.error("Unable to get configuration updates stream")
            return
        }
        for try await config in configStream {
            configuration = config
        }
    }
}
