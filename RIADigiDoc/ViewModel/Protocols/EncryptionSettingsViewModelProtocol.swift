// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
@MainActor
public protocol EncryptionSettingsViewModelProtocol: Sendable {
    var certData: Data? { get }
    var encryptionCdocOption: EncryptionCdocOption { get }
    var useKeyTransfer: Bool { get }
    var serverId: String { get }
    var serverInfo: EncryptionServerInfo { get }
    var isImportingCert: Bool { get }
    var isLoading: Bool { get }

    // MARK: - Init helpers
    func initializeSettings() async

    // MARK: - Setters
    func saveSettings() async

    // MARK: - Cert Info Getters
    func getCertIssuer() -> String
    func getCertNotValidAfter(expiredLabel: String) -> String

    // MARK: - Cert Import
    func importCert(from url: URL) async
}
