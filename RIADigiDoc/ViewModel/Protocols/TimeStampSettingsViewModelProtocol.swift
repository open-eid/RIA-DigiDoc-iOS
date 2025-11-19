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
import Foundation

/// @mockable
@MainActor
public protocol TimeStampSettingsViewModelProtocol: Sendable {
    var tsaUrl: String { get }
    var selectedOption: ServicesSettingsOption { get }
    var tsaCertData: Data? { get }
    var isImportingTSACert: Bool { get }
    var isLoading: Bool { get }

    // MARK: - Init helpers
    func initializeSettings() async

    // MARK: Saving
    func saveSettings() async

    // MARK: TSA Cert Info Getters
    func getTSACertIssuer() -> String
    func getTSACertNotValidAfter(expiredLabel: String) -> String

    // MARK: - TSA Cert Import
    func importTSACert(from url: URL) async

    // MARK: - Observer
    func observeConfigurationUpdates() async throws
    func removeObservers() async
}
