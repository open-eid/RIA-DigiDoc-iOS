// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol FileInspectorProtocol: Sendable {
    func fileSize(for url: URL) throws -> Int
    func contentAccessDate(for url: URL) throws -> Date
    func lastOpened(for url: URL) throws -> Date
}
