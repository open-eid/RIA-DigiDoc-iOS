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

import Foundation
import CommonsLib
import ConfigLib
import UtilsLib

public final class CDoc2Setting: NSObject, Sendable, Loggable {
    @objc @MainActor static public var isEncryptionEnabled: Bool = Constants.CryptoDefaultValues.encryptionUseCdoc2
    @objc @MainActor static public var isOnlineEncryptionEnabled: Bool =
        Constants.CryptoDefaultValues.encryptionUseKeyTransfer
    @objc @MainActor static public var getUUID: String = Constants.CryptoDefaultValues.encryptionServerInfoUUID
    @objc @MainActor static public var getFetchURL: String = Constants.CryptoDefaultValues.encryptionServerInfoFetchURL
    @objc @MainActor static public var getPostURL: String = Constants.CryptoDefaultValues.encryptionServerInfoPostURL

    @MainActor static public var cdoc2Conf: [String: ConfigurationProvider.CDOC2Conf] = [:]

    @MainActor @objc static public var getCert: Data = Data()

    @MainActor @objc public static var cdoc2Certs = [Data]()

    @MainActor
    public static func setEncryptionEnabled(_ val: Bool) {
       Self.isEncryptionEnabled = val
    }

    @MainActor
    public static func setOnlineEncryptionEnabled(_ val: Bool) {
       Self.isOnlineEncryptionEnabled = val
    }

    @MainActor
    public static func setUUID(_ val: String) {
       Self.getUUID = val
    }

    @MainActor
    public static func setPostURL(_ val: String) {
       Self.getPostURL = val
    }

    @MainActor
    public static func setFetchURL(_ val: String) {
       Self.getFetchURL = val
    }

    @MainActor
    public static func setCDoc2Conf(_ val: [String: ConfigurationProvider.CDOC2Conf]) {
       Self.cdoc2Conf = val
    }

    @objc public static let kProxyHost = "kProxyHost"
    @objc public static let kProxyPort = "kProxyPort"
    @objc public static let kProxyUsername = "kProxyUsername"
    @objc public static let kProxyPassword = "kProxyPassword"

    @objc @MainActor public static func getEncryptionServerInfoFetchURL(domain: String) -> String? {
        let conf = cdoc2Conf[domain]
        if let cdoc2ConfFetchUrl = conf?.fetchURL {
            return cdoc2ConfFetchUrl.absoluteString
        }
        return self.getFetchURL
    }

    @objc @MainActor public static func getEncryptionServerInfoPostURL(domain: String) -> String? {
        let conf = cdoc2Conf[domain]
        if let cdoc2ConfPostUrl = conf?.postURL {
            return cdoc2ConfPostUrl.absoluteString
        }
        return self.getPostURL
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
            "kProxyHost": host,
            "kProxyPort": port,
            "kProxyUsername": username,
            "kProxyPassword": password
        ]
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
                logger().error("Keychain lookup failed (\(status)): \(message)")
                return nil
            }
        }

}
