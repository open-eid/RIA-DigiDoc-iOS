//
//  CryptoDataFile.swift
//  CryptoLib
/*
 * Copyright 2017 - 2024 Riigi Infosüsteemi Amet
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

public final class CDoc2Settings: NSObject, Sendable {

    private static let logger = Logger(
        subsystem: "ee.ria.digidoc.RIADigiDoc",
        category: "CDoc2Settings"
    )

    public static let kUseCDoc2Encryption = Constants.CryptoKeys.encryptionUseCdoc2
    public static let kUseCDoc2OnlineEncryption = Constants.CryptoKeys.encryptionUseKeyTransfer
    public static let kCDoc2UUID = Constants.CryptoKeys.encryptionServerInfoUUID
    public static let kCDoc2FetchURL = Constants.CryptoKeys.encryptionServerInfoFetchURL
    public static let kCDoc2PostURL = Constants.CryptoKeys.encryptionServerInfoPostURL
    public static let kCDoc2Cert = Constants.CryptoKeys.encryptionCert
    @objc public static let kProxyHost = "kProxyHost"
    @objc public static let kProxyPort = "kProxyPort"
    @objc public static let kProxyUsername = "kProxyUsername"
    @objc public static let kProxyPassword = "kProxyPassword"

    private static func set<T>(_ key: String, value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private static func get<T>(_ key: String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }

    private static func keyExists(_ key: String) -> Bool {
        guard UserDefaults.standard.object(forKey: key) != nil else {
            return false
        }

        return true
    }

    public static var useEncryption: Bool {
        get { get(kUseCDoc2Encryption) ?? false }
        set { set(kUseCDoc2Encryption, value: newValue) }
    }

    public static var useOnlineEncryption: Bool {
        get { get(kUseCDoc2OnlineEncryption) ?? true }
        set { set(kUseCDoc2OnlineEncryption, value: newValue) }
    }

    public static var cdoc2UUID: String? {
        get { get(kCDoc2UUID) }
        set { set(kCDoc2UUID, value: newValue) }
    }

    public static var cdoc2PostURL: String? {
        get { get(kCDoc2PostURL) }
        set { set(kCDoc2PostURL, value: newValue) }
    }

    public static var cdoc2FetchURL: String? {
        get { get(kCDoc2FetchURL) }
        set { set(kCDoc2FetchURL, value: newValue) }
    }

    public static var cdoc2Cert: Data? {
        get { get(kCDoc2Cert) }
        set { set(kCDoc2Cert, value: newValue) }
    }

    @MainActor @objc public static var cdoc2Certs = [Data]()

    @objc public static func isEncryptionEnabled() -> Bool {
        return useEncryption
    }

    @objc public static func isOnlineEncryptionEnabled() -> Bool {
        return useOnlineEncryption
    }

    @objc public static func getUUID() -> String? {
        return cdoc2UUID
    }

    @objc public static func getPostURL() -> String? {
        return cdoc2PostURL
    }

    @objc public static func getFetchURL() -> String? {
        return cdoc2FetchURL
    }

    @objc public static func getEncryptionServerInfoFetchURL(domain: String) -> String? {
        if keyExists(Constants.CryptoKeys.encryptionServerInfoFetchURL + "_" + domain) {
            return get(Constants.CryptoKeys.encryptionServerInfoFetchURL + "_" + domain)
        }

        return getFetchURL()
    }

    @objc public static func getEncryptionServerInfoPostURL(domain: String) -> String? {
        if keyExists(Constants.CryptoKeys.encryptionServerInfoPostURL + "_" + domain) {
            return get(Constants.CryptoKeys.encryptionServerInfoPostURL + "_" + domain)
        }

        return getPostURL()
    }

    @objc public static func getCert() -> Data? {
        return cdoc2Cert
    }

    private static func findProxy(withData data: Bool = false) -> [String: Any]? {
        let returnData: CFBoolean = data ? kCFBooleanTrue : kCFBooleanFalse

        let query: [CFString: Any] = [
            kSecClass: kSecClassInternetPassword,
            kSecAttrLabel: "proxy" as CFString,
            kSecReturnAttributes: kCFBooleanTrue as CFBoolean,
            kSecReturnData: returnData,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            return item as? [String: Any]
        case errSecItemNotFound:
            return nil
        default:
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            logger.error("Keychain lookup failed (\(status)): \(message)")
            return nil
        }
    }

    @objc public static func proxyCredentials() -> [String: Any]? {
        guard let result = findProxy(withData: true),
              let host = result[kSecAttrServer as String] as? String,
              let port = result[kSecAttrPort as String] as? Int,
              let username = result[kSecAttrAccount as String] as? String,
              let passwordData = result[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            return nil
        }
        return [
            kProxyHost: host,
            kProxyPort: port,
            kProxyUsername: username,
            kProxyPassword: password
        ]
    }

    public static func setProxyCredentials(host: String, port: Int, username: String, password: String) {
        guard let passwordData = password.data(using: .utf8) else {
            logger.error("Failed to convert password to UTF-8 data")
            return
        }

        if let existing = findProxy(),
           let existingServer = existing[kSecAttrServer as String] as? String,
           let existingAccount = existing[kSecAttrAccount as String] as? String {

            var updateQuery: [CFString: Any] = [
                kSecClass: kSecClassInternetPassword,
                kSecAttrLabel: "proxy" as CFString,
                kSecAttrServer: existingServer,
                kSecAttrAccount: existingAccount
            ]

            // Include port if present and numeric
            if let existingPort = existing[kSecAttrPort as String] as? NSNumber {
                updateQuery[kSecAttrPort] = existingPort
            } else if let existingPortInt = existing[kSecAttrPort as String] as? Int {
                updateQuery[kSecAttrPort] = existingPortInt
            }

            let updateAttrs: [CFString: Any] = [
                kSecAttrLabel: "proxy" as CFString,
                kSecAttrServer: host as CFString,
                kSecAttrPort: port,
                kSecAttrAccount: username as CFString,
                kSecValueData: passwordData
            ]

            let status = SecItemUpdate(updateQuery as CFDictionary, updateAttrs as CFDictionary)
            if status != errSecSuccess {
                let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
                logger.error("Keychain update failed (\(status)): \(message)")
            }

        } else {
            let attributes: [CFString: Any] = [
                kSecClass: kSecClassInternetPassword,
                kSecAttrLabel: "proxy" as CFString,
                kSecAttrServer: host as CFString,
                kSecAttrPort: port,
                kSecAttrAccount: username as CFString,
                kSecValueData: passwordData
            ]

            let status = SecItemAdd(attributes as CFDictionary, nil)
            if status != errSecSuccess {
                let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
                logger.error("Keychain add failed (\(status)): \(message)")
            }
        }
    }

    public static func clearProxyCredentials() {
        guard
            let item = findProxy(),
            let server = item[kSecAttrServer as String] as? String,
            let account = item[kSecAttrAccount as String] as? String
        else {
            return
        }

        var deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: account
        ]

        // Port is optional; include it if present and well-typed
        if let port = item[kSecAttrPort as String] as? NSNumber {
            deleteQuery[kSecAttrPort as String] = port
        } else if let portInt = item[kSecAttrPort as String] as? Int {
            deleteQuery[kSecAttrPort as String] = portInt
        }

        let status = SecItemDelete(deleteQuery as CFDictionary)
        if status != errSecSuccess {
            let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error"
            logger.error("Keychain delete failed (\(status)): \(message)")
        }
    }
}
