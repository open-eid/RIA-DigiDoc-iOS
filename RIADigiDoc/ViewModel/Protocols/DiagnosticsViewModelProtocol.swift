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
    var urlSectionContent: [(key: String, content: String)] { get }
    var cdoc2SectionContent: [String] { get }
    var tslSectionContent: [String] { get }
    var centralConfigurationSectionContent: [(key: String, content: String)] { get }

    // MARK: Fetching
    func getConfigurationData(configuration: ConfigurationProvider?, tslSchemaDirectory: URL?) async

    // MARK: Actions
    func updateConfiguration() async -> Bool
    func createLogFile(languageSettings: LanguageSettingsProtocol, directory: URL?) async -> URL?
    func removeLogFilesDirectory()

    func removeObservers() async
}
