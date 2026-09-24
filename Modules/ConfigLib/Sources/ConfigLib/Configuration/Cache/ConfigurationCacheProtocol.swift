// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

/// @mockable
public protocol ConfigurationCacheProtocol: Sendable {
    func cacheConfigurationFiles(
        confData: String,
        signature: String,
        configDir: URL
    ) async throws

    func getCachedFile(
        fileName: String,
        configDir: URL
    ) async throws -> URL
}
