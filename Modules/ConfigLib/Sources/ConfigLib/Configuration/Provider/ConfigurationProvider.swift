/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
import UtilsLib

extension Dictionary where Key == String, Value == ConfigurationProvider.CDOC2Conf {
    public func asNSDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        result.reserveCapacity(self.count)

        for (uuid, conf) in self {
            result[uuid] = [
                "NAME": conf.name,
                "POST": conf.postURL.absoluteString,
                "FETCH": conf.fetchURL.absoluteString
            ]
        }

        return result
    }
}

public struct ConfigurationProvider: Codable, Sendable, Equatable {
    public struct MetaInf: Codable, Sendable, Equatable {
        public let url: String
        public let date: String
        public let serial: Int
        public let version: Int

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case url = "URL"
            case date = "DATE"
            case serial = "SERIAL"
            case version = "VER"
        }

        public init(url: String, date: String, serial: Int, version: Int) {
            self.url = url
            self.date = date
            self.serial = serial
            self.version = version
        }
    }

    public struct CDOC2Conf: Codable, Sendable, Equatable {
        public let name: String
        public let postURL: URL
        public let fetchURL: URL

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case name = "NAME"
            case postURL = "POST"
            case fetchURL = "FETCH"
        }

        public init(name: String, postURL: URL, fetchURL: URL) {
            self.name = name
            self.postURL = postURL
            self.fetchURL = fetchURL
        }

        public func asDictionary(uuid: String) -> [String: Any] {
            guard
                let data = try? JSONEncoder().encode(self),
                let confDict = try? JSONSerialization.jsonObject(with: data),
                let dict = confDict as? [String: Any]
            else {
                return [:]
            }

            return [uuid: dict]
        }
    }

    public let metaInf: MetaInf
    public let sivaUrl: URL
    public let tslUrl: URL
    public let tslCerts: [Data]
    public let tsaUrl: URL
    public let ldapPersonUrls: [URL]
    public let ldapPersonUrl: URL
    public let ldapCorpUrl: URL
    public let midRestUrl: URL
    public let midSkRestUrl: URL
    public let sidV2RestUrl: URL
    public let sidV2SkRestUrl: URL
    public let certBundle: [Data]
    public let ldapCerts: [Data]
    public var configurationLastUpdateCheckDate: Date?
    public var configurationUpdateDate: Date?
    public let cdoc2Default: Bool?
    public let cdoc2DefaultKeyserver: String
    public let cdoc2UseKeyserver: Bool
    public let cdoc2Conf: [String: CDOC2Conf]

    private enum CodingKeys: String, CodingKey {
        case metaInf = "META-INF"
        case sivaUrl = "SIVA-URL"
        case tslUrl = "TSL-URL"
        case tslCerts = "TSL-CERTS"
        case tsaUrl = "TSA-URL"
        case ldapPersonUrls = "LDAP-PERSON-URLS"
        case ldapPersonUrl = "LDAP-PERSON-URL"
        case ldapCorpUrl = "LDAP-CORP-URL"
        case midRestUrl = "MID-PROXY-URL"
        case midSkRestUrl = "MID-SK-URL"
        case sidV2RestUrl = "SIDV2-PROXY-URL"
        case sidV2SkRestUrl = "SIDV2-SK-URL"
        case certBundle = "CERT-BUNDLE"
        case ldapCerts = "LDAP-CERTS"
        case configurationLastUpdateCheckDate = "configurationLastUpdateCheckDate"
        case configurationUpdateDate = "configurationUpdateDate"
        case cdoc2Default = "CDOC2-DEFAULT"
        case cdoc2DefaultKeyserver = "CDOC2-DEFAULT-KEYSERVER"
        case cdoc2UseKeyserver = "CDOC2-USE-KEYSERVER"
        case cdoc2Conf = "CDOC2-CONF"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container
            .encodeIfPresent(
                configurationLastUpdateCheckDate?.formatted(),
                forKey: .configurationLastUpdateCheckDate
            )
        try container.encodeIfPresent(configurationUpdateDate?.formatted(), forKey: .configurationUpdateDate)

        try container.encode(metaInf, forKey: .metaInf)
        try container.encode(sivaUrl, forKey: .sivaUrl)
        try container.encode(tslUrl, forKey: .tslUrl)
        try container.encode(tslCerts, forKey: .tslCerts)
        try container.encode(tsaUrl, forKey: .tsaUrl)
        try container.encode(ldapPersonUrl, forKey: .ldapPersonUrl)
        try container.encode(ldapPersonUrls, forKey: .ldapPersonUrls)
        try container.encode(ldapCorpUrl, forKey: .ldapCorpUrl)
        try container.encode(midRestUrl, forKey: .midRestUrl)
        try container.encode(midSkRestUrl, forKey: .midSkRestUrl)
        try container.encode(sidV2RestUrl, forKey: .sidV2RestUrl)
        try container.encode(sidV2SkRestUrl, forKey: .sidV2SkRestUrl)
        try container.encode(certBundle, forKey: .certBundle)
        try container.encode(ldapCerts, forKey: .ldapCerts)
        try container.encode(cdoc2Default, forKey: .cdoc2Default)
        try container.encode(cdoc2DefaultKeyserver, forKey: .cdoc2DefaultKeyserver)
        try container.encode(cdoc2UseKeyserver, forKey: .cdoc2UseKeyserver)
        try container.encode(cdoc2Conf, forKey: .cdoc2Conf)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        metaInf = try container.decode(MetaInf.self, forKey: .metaInf)
        sivaUrl = try container.decode(URL.self, forKey: .sivaUrl)
        tslUrl = try container.decode(URL.self, forKey: .tslUrl)
        tslCerts = try container.decode([Data].self, forKey: .tslCerts)
        tsaUrl = try container.decode(URL.self, forKey: .tsaUrl)
        ldapPersonUrls = try container.decode([URL].self, forKey: .ldapPersonUrls)
        ldapPersonUrl = try container.decode(URL.self, forKey: .ldapPersonUrl)
        ldapCorpUrl = try container.decode(URL.self, forKey: .ldapCorpUrl)
        midRestUrl = try container.decode(URL.self, forKey: .midRestUrl)
        midSkRestUrl = try container.decode(URL.self, forKey: .midSkRestUrl)
        sidV2RestUrl = try container.decode(URL.self, forKey: .sidV2RestUrl)
        sidV2SkRestUrl = try container.decode(URL.self, forKey: .sidV2SkRestUrl)
        certBundle = try container.decode([Data].self, forKey: .certBundle)
        ldapCerts = try container.decode([Data].self, forKey: .ldapCerts)
        cdoc2Default = try container.decodeIfPresent(Bool.self, forKey: .cdoc2Default)
        cdoc2DefaultKeyserver = try container.decode(String.self, forKey: .cdoc2DefaultKeyserver)
        cdoc2UseKeyserver = try container.decode(Bool.self, forKey: .cdoc2UseKeyserver)
        cdoc2Conf = try container.decode([String: CDOC2Conf].self, forKey: .cdoc2Conf)

        let lastUpdateCheckString = try container.decodeIfPresent(
            String.self,
            forKey: .configurationLastUpdateCheckDate
        )
        let updateDateString = try container.decodeIfPresent(String.self, forKey: .configurationUpdateDate)

        configurationLastUpdateCheckDate = lastUpdateCheckString.flatMap { DateUtil.dateFormatter.date(from: $0) }
        configurationUpdateDate = updateDateString.flatMap { DateUtil.dateFormatter.date(from: $0) }
    }

    public init(
        metaInf: MetaInf,
        sivaUrl: URL,
        tslUrl: URL,
        tslCerts: [Data],
        tsaUrl: URL,
        ldapPersonUrls: [URL],
        ldapPersonUrl: URL,
        ldapCorpUrl: URL,
        midRestUrl: URL,
        midSkRestUrl: URL,
        sidV2RestUrl: URL,
        sidV2SkRestUrl: URL,
        certBundle: [Data],
        ldapCerts: [Data],
        configurationLastUpdateCheckDate: Date?,
        configurationUpdateDate: Date?,
        cdoc2Default: Bool?,
        cdoc2DefaultKeyserver: String,
        cdoc2UseKeyserver: Bool,
        cdoc2Conf: [String: CDOC2Conf],
    ) {
        self.metaInf = metaInf
        self.sivaUrl = sivaUrl
        self.tslUrl = tslUrl
        self.tslCerts = tslCerts
        self.tsaUrl = tsaUrl
        self.ldapPersonUrls = ldapPersonUrls
        self.ldapPersonUrl = ldapPersonUrl
        self.ldapCorpUrl = ldapCorpUrl
        self.midRestUrl = midRestUrl
        self.midSkRestUrl = midSkRestUrl
        self.sidV2RestUrl = sidV2RestUrl
        self.sidV2SkRestUrl = sidV2SkRestUrl
        self.certBundle = certBundle
        self.ldapCerts = ldapCerts
        self.configurationLastUpdateCheckDate = configurationLastUpdateCheckDate
        self.configurationUpdateDate = configurationUpdateDate
        self.cdoc2Default = cdoc2Default
        self.cdoc2DefaultKeyserver = cdoc2DefaultKeyserver
        self.cdoc2UseKeyserver = cdoc2UseKeyserver
        self.cdoc2Conf = cdoc2Conf
    }
}
