/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
