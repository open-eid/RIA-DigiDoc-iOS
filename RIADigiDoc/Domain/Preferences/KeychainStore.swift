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

import CommonsLib
import Foundation
import OSLog

public actor KeychainStore: KeychainStoreProtocol {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "KeychainStore")

    private let bundleIdentifier: String

    public init(bundleIdentifier: String? = nil) {
        self.bundleIdentifier = bundleIdentifier ?? BundleUtil.getBundleIdentifier()
    }

    public func save(key: KeychainKey, info: Data, withPasscodeSetOnly: Bool = false) async -> Bool {
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
            await KeychainStore.logger.error("Unable to save \(key.rawValue): \(status)")
            return false
        }
    }

    public func save(key: KeychainKey, info: Data) async -> Bool {
        return await save(key: key, info: info, withPasscodeSetOnly: false)
    }

    public func retrieve(key: KeychainKey) async -> Data? {
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

    public func remove(key: KeychainKey) async {
        let query = baseQuery(key: key)
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess {
            await KeychainStore.logger.error("Error removing key from Keychain: \(status)")
        }
    }

    public func removeAll() async {
        for key in KeychainKey.allCases {
            await remove(key: key)
        }
    }

    // MARK: - Helper Methods
    private func baseQuery(key: KeychainKey) -> [CFString: Any] {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: bundleIdentifier,
            kSecAttrAccount: "\(bundleIdentifier).\(key.rawValue)"
        ]
    }
}
