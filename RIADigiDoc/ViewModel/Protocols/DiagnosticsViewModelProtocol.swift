// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import ConfigLib
import CommonsLib

/// @mockable
@MainActor
public protocol DiagnosticsViewModelProtocol: Sendable {
    // MARK: Published properties
    var enableOneTimeLogGeneration: Bool { get }
    var showSaveLogButton: Bool { get }
    var showRestartActivateAlert: Bool { get }
    var showRestartDeactivateAlert: Bool { get }

    var versionSectionContent: String { get }
    var osSectionContent: (key: String, content: String) { get }
    var libdigidocVersion: String { get }
    var urlSectionContent: [(key: String, content: String)] { get }
    var cdoc2SectionContent: [String] { get }
    var settingsSectionContent: [String] { get }
    var tslSectionContent: [String] { get }
    var centralConfigurationSectionContent: [(key: String, content: String)] { get }

    // MARK: Fetching
    func getConfigurationData(configuration: ConfigurationProvider?, tslSchemaDirectory: URL?) async

    // MARK: Actions
    func updateConfiguration() async -> Bool
    func createDiagnosticsFile(languageSettings: LanguageSettingsProtocol, directory: URL?) async -> URL?
    func onDiagnosticsFileSavingComplete()
    func onEnableOneTimeLogGenerationChange(_ isEnabled: Bool) async
    func createLogFile(directory: URL?) async -> URL?
    func onLogFileSavingComplete() async

    func removeObservers() async
    func getRpUuid() async -> String
    func getTsaUrl() async -> String
    func getSivaUrl() async -> String
    func observeConfigurationUpdates() async
}
