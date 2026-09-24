// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
}
