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

@Observable
@MainActor
class DiagnosticsViewModel: DiagnosticsViewModelProtocol, Loggable {
    var configuration: ConfigurationProvider?

    var enableOneTimeLogGeneration = false
    var showSaveLogButton = false
    var showRestartActivateAlert = false
    var showRestartDeactivateAlert = false

    var showRestartText = false

    // MARK: - section content
    var versionSectionContent: String = ""
    var osSectionContent: (key: String, content: String) = (key: "", content: "")
    var libdigidocVersion: String = ""
    var urlSectionContent: [(key: String, content: String)] = [(key: "", content: "")]
    var cdoc2SectionContent: [String] = [""]
    var tslSectionContent: [String] = [""]
    var centralConfigurationSectionContent: [(key: String, content: String)] = [(key: "", content: "")]

    // MARK: - dependencies
    private let containerWrapper: ContainerWrapperProtocol
    private let fileManager: FileManagerProtocol
    private let configurationLoader: ConfigurationLoaderProtocol
    private let configurationRepository: ConfigurationRepositoryProtocol
    private let tslUtil: TSLUtilProtocol
    private let dataStore: DataStoreProtocol
    private let proxyUtil: ProxyUtilProtocol
    private let userAgentUtil: UserAgentUtilProtocol
    private let fileUtil: FileUtilProtocol
    private let cryptoSetup: CryptoSetupProtocol

    private var configurationObservationTask: Task<Void, Never>?

    init(
        containerWrapper: ContainerWrapperProtocol,
        fileManager: FileManagerProtocol,
        configurationLoader: ConfigurationLoaderProtocol,
        configurationRepository: ConfigurationRepositoryProtocol,
        tslUtil: TSLUtilProtocol,
        dataStore: DataStoreProtocol,
        proxyUtil: ProxyUtilProtocol,
        userAgentUtil: UserAgentUtilProtocol,
        fileUtil: FileUtilProtocol,
        cryptoSetup: CryptoSetupProtocol
    ) {
        self.containerWrapper = containerWrapper
        self.fileManager = fileManager
        self.configurationLoader = configurationLoader
        self.configurationRepository = configurationRepository
        self.tslUtil = tslUtil
        self.dataStore = dataStore
        self.proxyUtil = proxyUtil
        self.userAgentUtil = userAgentUtil
        self.fileUtil = fileUtil
        self.cryptoSetup = cryptoSetup

        configurationObservationTask = Task {
            await observeConfigurationUpdates()
        }

        Task {
            await loadLibdigidocVersion()
            await loadLoggingVariables()
        }
    }

    public func removeObservers() async {
        configurationObservationTask?.cancel()
    }

    // MARK: - Fetching content - public

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

    // MARK: - Fetching content - private

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

        let rpUuid = await getRpUuid()

        self.urlSectionContent = [
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
            ("RPUUID", rpUuid == Constants.Signing.RelyingPartyUUID
             ? "Main diagnostics rpuuid default"
             : rpUuid
            )
        ]
    }

    private func loadCdoc2SectionContent(configuration: ConfigurationProvider?) {
        guard let config = configuration else { return }

        let lines: [(label: String, value: String)] = [
            ("CDOC2-DEFAULT", String(config.cdoc2Default ?? false)),
            ("CDOC2-USE-KEYSERVER", String(config.cdoc2UseKeyserver)),
            ("CDOC2-DEFAULT-KEYSERVER", config.cdoc2DefaultKeyserver)
        ]

        self.cdoc2SectionContent = lines.map { "\($0.label): \($0.value)" }
    }

    private func loadTslSectionContent(schemaDirectory: URL? = nil) {
        let directory = schemaDirectory ?? Directories.getLibraryDirectory(fileManager: fileManager)
        guard let schemaDirectory = directory else {
            DiagnosticsViewModel.logger().error("Unable to get the schema directory")
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
                    DiagnosticsViewModel.logger().error(
                        "Failed to parse \(fileURL): \(error.localizedDescription)")
                    filesWithSequenceNumber.append(fileName)
                }
            }

            self.tslSectionContent = filesWithSequenceNumber

        } catch {
            DiagnosticsViewModel.logger().error("Could not list TSL directory: \(error)")
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

    // MARK: - Create Diagnostics File - public

    func createDiagnosticsFile(languageSettings: LanguageSettingsProtocol, directory: URL? = nil) async -> URL? {
        let diagnosticsText = buildDiagnosticsText(languageSettings: languageSettings)
        let diagnosticsFileName = "ria_digidoc_\(self.versionSectionContent)_diagnostics.log"
        return writeToTempFile(
            content: diagnosticsText,
            fileName: diagnosticsFileName,
            directory: directory
        )
    }

    func onDiagnosticsFileSavingComplete() {
        fileUtil.removeCacheLogsDirectory()
    }

    // MARK: - Create Diagnostics File - private

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
        lines.append(contentsOf: self.urlSectionContent.map {
            "\($0.key): \(languageSettings.localized($0.content))"
        })
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

    private func getTempFileURL(fileName: String, directory: URL? = nil) throws -> URL {
        let savedFilesDirectory = try directory ?? Directories.getCacheDirectory(
            subfolders: [CommonsLib.Constants.Folder.Logs],
            fileManager: fileManager
        )
        return savedFilesDirectory.appending(path: fileName)
    }

    // MARK: - Update configuration - public

    func updateConfiguration() async -> Bool {
        do {
            let configDirectory = try Directories.getCacheDirectory(
                fileManager: fileManager
            ).appending(path:
                CommonsLib.Constants.Configuration.CacheConfigFolder
            )
            let proxyInfo = await proxyUtil.getProxyInfo()
            let appLanguage = await dataStore.getSelectedLanguage()
            let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: appLanguage)
            try await configurationLoader.loadCentralConfiguration(
                cacheDir: configDirectory,
                proxyInfo: proxyInfo,
                userAgent: userAgent
            )
            DiagnosticsViewModel.logger().info("Configuration updated successfully")
            return true
        } catch let error as URLError where error.code == .resourceUnavailable {
            DiagnosticsViewModel.logger().error("Unable to update configuration. No Internet connection. \(error)")
            return false
        } catch {
            DiagnosticsViewModel.logger().error("Unable to update configuration: \(error)")
            return false
        }
    }

    // MARK: - Creating Log - public

    public func onEnableOneTimeLogGenerationChange(_ isEnabled: Bool) async {
        let dataStoreValue = await dataStore.getEnableLoggingNextSession()
        if isEnabled == dataStoreValue {
            return
        }

        if isEnabled {
            self.showRestartActivateAlert = true
        }
        await dataStore.setEnableLoggingNextSession(isEnabled)

        showRestartText = isEnabled

        if !isEnabled {
            showSaveLogButton = false
            removeAllLogFiles()
            await dataStore.setEnableLoggingThisSession(false)
        }
    }

    public func createLogFile(directory: URL? = nil) async -> URL? {
        let appLogEntries = await readAppLogEntries()
        let libdigidocLogEntries = await readLibDigidocLogEntries()
        let mergedLines = mergeLogEntries(appLogEntries, libdigidocLogEntries)
        let logFileName = "ria_digidoc_\(self.versionSectionContent).log"
        return writeToTempFile(
            content: mergedLines,
            fileName: logFileName,
            directory: directory
        )
    }

    public func onLogFileSavingComplete() async {
        removeAllLogFiles()

        await dataStore.setEnableLoggingNextSession(false)
        await dataStore.setIsLogFileSaved(true)
        self.showRestartText = true
        self.enableOneTimeLogGeneration = false
        self.showSaveLogButton = false
        self.showRestartDeactivateAlert = true
    }

    // MARK: - Creating Log - private

    private func loadLoggingVariables() async {
        enableOneTimeLogGeneration = await dataStore.getEnableLoggingNextSession()
        let enableLoggingThisSession = await dataStore.getEnableLoggingThisSession()
        let isLogFileSaved = await dataStore.getIsLogFileSaved()
        showSaveLogButton = enableLoggingThisSession && !isLogFileSaved

        if (enableOneTimeLogGeneration && !showSaveLogButton) ||
            (enableLoggingThisSession && isLogFileSaved) {
            showRestartText = true
        }
    }

    private func writeToTempFile(content: String, fileName: String, directory: URL?) -> URL? {
        do {
            let fileURL = try getTempFileURL(fileName: fileName, directory: directory)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            DiagnosticsViewModel.logger().error("Unable to write \"\(fileName)\" file: \(error)")
        }
        return nil
    }

    private func removeAllLogFiles() {
        fileUtil.removeCacheLogsDirectory()
        fileUtil.removeLibraryLogsDirectory(directory: nil)
    }

    private func entriesToLines(_ entries: AnySequence<OSLogEntry>) -> [String] {
        var lines = [String]()
        for entry in entries {
            if let log = entry as? OSLogEntryLog {
                lines.append("""
                      \(entry.date) \
                      [\(log.subsystem):\(log.category)] - \
                      \(entry.composedMessage)
                      """)
            } else {
                lines.append("\(entry.date): \(entry.composedMessage)\n")
            }
        }
        return lines
    }

    private func readAppLogEntries() async -> [String]? {
        return await withCheckedContinuation { continuation in
            Task.detached(priority: .userInitiated) {
                do {
                    let store = try OSLogStore(scope: .currentProcessIdentifier)
                    let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())
                    guard let yesterday = oneDayAgo else {
                        continuation.resume(returning: nil)
                        return
                    }

                    let position = store.position(date: yesterday)
                    let bundleIdentifier = BundleUtil.getBundleIdentifier()
                    let predicate = NSPredicate(
                        format: "subsystem BEGINSWITH %@",
                        bundleIdentifier
                    )
                    let entries = try store.getEntries(at: position, matching: predicate)
                    let lines = await self.entriesToLines(entries)
                    continuation.resume(returning: lines)
                } catch {
                    DiagnosticsViewModel.logger().error("Unable to get app log entries: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func readLibDigidocLogEntries() async -> [String]? {
        if let libdigidocLogURL = await getLibDigidocLogURL() {
            return getLines(from: libdigidocLogURL)
        }
        return nil
    }

    private func getLibDigidocLogURL() async -> URL? {
        do {
            return try Directories.getLibdigidocLogFile(
                from: Directories.getLibraryDirectory(fileManager: fileManager),
                fileManager: fileManager
            )
        } catch {
            DiagnosticsViewModel.logger().error("Unable to get libdigidoc log URL: \(error)")
        }
        return nil
    }

    private func getLines(from url: URL?) -> [String] {
        guard let url = url, fileManager.fileExists(atPath: url.path) else { return [] }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        } catch {
            return []
        }
    }

    private func mergeLogEntries(_ appLogEntries: [String]?, _ libDigidocLogEntries: [String]?) -> String {
        var allEntries: [String] = []

        allEntries.append("===== File: \(Constants.File.LibDigidocLog) =====")
        allEntries.append("")
        if let libDigidocLogEntries = libDigidocLogEntries {
            allEntries.append(contentsOf: libDigidocLogEntries)
        }

        allEntries.append("")
        allEntries.append("")
        allEntries.append("===== File: ria_digidoc.log =====")
        allEntries.append("")
        if let appLogEntries = appLogEntries {
            allEntries.append(contentsOf: appLogEntries)
        }

        return allEntries.joined(separator: "\n")
    }

    // MARK: - Observer

    public func observeConfigurationUpdates() async {
        guard !Task.isCancelled else {
            return
        }

        guard let configStream = await configurationRepository.observeConfigurationUpdates() else {
            DiagnosticsViewModel.logger().error("Unable to get configuration updates stream")
            return
        }

        do {
            for try await config in configStream {
                await MainActor.run {
                    configuration = config
                }
                await cryptoSetup.setCdoc2Config(config)
                await cryptoSetup.setCdoc2Settings(config)
            }
        } catch {
            DiagnosticsViewModel.logger().error("Unable to get configuration from stream")
        }
    }
}
