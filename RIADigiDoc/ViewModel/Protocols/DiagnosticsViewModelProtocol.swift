import Foundation
import CommonsLib

/// @mockable
@MainActor
public protocol DiagnosticsViewModelProtocol: Sendable {
    // MARK: Published properties
    var versionSectionContent: String { get }
    var osSectionContent: String { get }
    var libdigidocVersion: String { get }
    var urlSectionContent: [String] { get }
    var cdoc2SectionContent: [String] { get }
    var tslSectionContent: [String] { get }
    var centralConfigurationSectionContent: [String] { get }

    // MARK: Fetching
    func fetchContent(languageSettings: LanguageSettingsProtocol, tslSchemaDirectory: URL?)
    func fetchAsyncContent() async

    // MARK: Actions
    func updateConfiguration() async
    func createLogFile(languageSettings: LanguageSettingsProtocol, directory: URL?) async -> URL?
    func removeLogFilesDirectory()
}
