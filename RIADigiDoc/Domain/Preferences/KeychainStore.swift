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

import UtilsLib
import Foundation

public actor KeychainStore: KeychainStoreProtocol, Loggable {
    private let bundleIdentifier: String

    public init(bundleIdentifier: String? = nil) {
        self.bundleIdentifier = bundleIdentifier ?? BundleUtil.getBundleIdentifier()
    }

    public func save(key: String, info: Data, withPasscodeSetOnly: Bool = false) async -> Bool {
        let query = baseQuery(key: key)

        let attributes: [CFString: Any] = [
            kSecValueData: info,
            kSecAttrAccessible: withPasscodeSetOnly
            ? kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            : kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecSuccess {
            return true
        } else if status == errSecItemNotFound {
            // Item does not exist yet, add it
            let queryWithAttributes = query.merging(attributes) { (_, new) in new }

            let addStatus = SecItemAdd(queryWithAttributes as CFDictionary, nil)
            return addStatus == errSecSuccess
        } else {
            KeychainStore.logger().error("Unable to save \(key): \(status)")
            return false
        }
    }

    public func save(key: String, info: Data) async -> Bool {
        return await save(key: key, info: info, withPasscodeSetOnly: false)
    }
    
    public func save(key: KeychainKey, info: Data) async -> Bool {
        return await save(key: key.rawValue, info: info, withPasscodeSetOnly: false)
    }

    public func retrieve(key: String) async -> Data? {
        var query = baseQuery(key: key)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        var infoData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &infoData)

        if status == errSecSuccess, let data = infoData as? Data {
            return data
        } else {
            return nil
        }
    }

    public func retrieve(key: KeychainKey) async -> Data? {
        return await retrieve(key: key.rawValue)
    }
    
    public func remove(key: String) async {
        let query = baseQuery(key: key)
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess {
            KeychainStore.logger().error("Error removing key from Keychain: \(status)")
        }
    }
    
    public func remove(key: KeychainKey) async {
        await remove(key: key.rawValue)
    }

    public func removeAll() async {
        for key in KeychainKey.allCases {
            await remove(key: key.rawValue)
        }
    }

    // MARK: - Helper Methods
    private func baseQuery(key: String) -> [CFString: Any] {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: bundleIdentifier,
            kSecAttrAccount: "\(bundleIdentifier).\(key)"
        ]
    }
}
