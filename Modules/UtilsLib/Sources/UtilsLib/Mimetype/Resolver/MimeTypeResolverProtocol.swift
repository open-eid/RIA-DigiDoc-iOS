// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol MimeTypeResolverProtocol: Sendable {
    func mimeType(url: URL) async -> String
}
