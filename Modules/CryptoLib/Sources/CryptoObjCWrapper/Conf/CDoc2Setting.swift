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

    @MainActor static public var proxyInfo: ProxyInfo? = nil
    
    @MainActor static public var cdoc2Conf: [String: ConfigurationProvider.CDOC2Conf] = [:]

    @MainActor @objc static public var cert: Data = Data()

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
    
    @MainActor
    public static func setProxyInfo(_ val: ProxyInfo) {
        Self.proxyInfo = val
    }
    
    @MainActor
    public static func setCertBundle(_ val: [Data]) {
        Self.cdoc2Certs = val
    }
    
    @MainActor
    public static func setCert(_ val: Data) {
        Self.cert = val
    }

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

    @objc public static let kProxyHost = "kProxyHost"
    @objc public static let kProxyPort = "kProxyPort"
    @objc public static let kProxyUsername = "kProxyUsername"
    @objc public static let kProxyPassword = "kProxyPassword"
    
    @objc @MainActor public static func proxyCredentials() -> [String: Any]? {
        return [
            kProxyHost: proxyInfo?.host ?? "",
            kProxyPort: proxyInfo?.port ?? 80,
            kProxyUsername: proxyInfo?.username ?? "",
            kProxyPassword: proxyInfo?.password ?? ""
        ]
    }
}
