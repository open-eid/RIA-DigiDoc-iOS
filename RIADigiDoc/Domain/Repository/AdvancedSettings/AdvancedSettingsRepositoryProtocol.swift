// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol AdvancedSettingsRepositoryProtocol: Sendable {
    func getCertificate(
        certificateFolder: String,
        certificateBaseName: String,
    ) async -> Data?

    func importCertificate(
        from url: URL,
        certificateFolder: String,
        certificateBaseName: String
    ) async -> Data?

    func removeAllCertFiles(certificateFolders: [String]) async throws
}
