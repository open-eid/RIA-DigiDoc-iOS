// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
            KeychainStore.logger().error("Unable to save keychain item: \(status)")
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

        if status != errSecSuccess, status != errSecItemNotFound {
            KeychainStore.logger().error("Error removing key from Keychain: \(status)")
        }
    }

    public func remove(key: KeychainKey) async {
        await remove(key: key.rawValue)
    }

    @discardableResult
    public func removeAll() async -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: bundleIdentifier
        ]
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess, status != errSecItemNotFound {
            KeychainStore.logger().error("Error removing all keys from Keychain: \(status)")
            return false
        }

        return true
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
