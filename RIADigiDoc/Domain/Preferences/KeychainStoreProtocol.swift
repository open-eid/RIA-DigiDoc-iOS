// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol KeychainStoreProtocol: Sendable {
    func save(key: String, info: Data, withPasscodeSetOnly: Bool) async -> Bool
    func save(key: String, info: Data) async -> Bool
    func save(key: KeychainKey, info: Data) async -> Bool
    func retrieve(key: String) async -> Data?
    func retrieve(key: KeychainKey) async -> Data?
    func remove(key: String) async
    func remove(key: KeychainKey) async
    @discardableResult
    func removeAll() async -> Bool
}
