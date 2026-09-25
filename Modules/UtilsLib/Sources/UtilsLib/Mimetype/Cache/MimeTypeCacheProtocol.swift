// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol MimeTypeCacheProtocol: Sendable {
    func getMimeType(fileUrl: URL) async -> String

    func setMimeType(md5: String, mimeType: String) async
}
