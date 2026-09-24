// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

@objc public protocol AbstractSmartToken {
    func getCertificate() async throws -> Data
    func decrypt(_ data: Data) async throws -> Data
    func derive(_ data: Data) async throws -> Data
    func authenticate(_ data: Data) async throws -> Data
}
