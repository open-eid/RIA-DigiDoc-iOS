import Foundation
import ConfigLib
import CommonsLib

/// @mockable
@MainActor
public protocol DiagnosticsViewModelProtocol: Sendable {
    // MARK: Published properties
    var versionSectionContent: String { get }
    var osSectionContent: (key: String, content: String) { get }
    var libdigidocVersion: String { get }
    var urlSectionContent: [String] { get }
    var cdoc2SectionContent: [String] { get }
    var tslSectionContent: [String] { get }
    var centralConfigurationSectionContent: [(key: String, content: String)] { get }

    // MARK: Fetching
    func getConfigurationData(configuration: ConfigurationProvider?, tslSchemaDirectory: URL?) async

    // MARK: Actions
    func updateConfiguration() async
    func createLogFile(languageSettings: LanguageSettingsProtocol, directory: URL?) async -> URL?
    func removeLogFilesDirectory()

    func removeObservers() async
}
