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
import OSLog
import CommonsTestShared

@testable import ConfigLib

public class TestConfigurationProvider {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "TestConfigurationProvider")

    public static func mockConfigurationProvider(
        metaInfUrl: String = "https://someUrl.abc",
        metaInfDate: String = "1970-01-01",
        metaInfSerial: Int = 1,
        metaInfVersion: Int = 1,
        sivaUrl: String = "https://siva.someUrl.abc",
        tslUrl: String = "https://tsl.someUrl.abc",
        tslCerts: [String] = ["cert1", "cert2"],
        tsaUrl: String = "https://tsa.someUrl.abc",
        ocspIssuers: [String: String] = ["url1": "issuer1"],
        ldapPersonUrls: [String] = [
            "https://ldap-person.someUrl.abc",
            "https://ldap-person.someUrl2.abc"
        ],
        ldapPersonUrl: String = "https://ldap-person.someUrl.abc",
        ldapCorpUrl: String = "https://ldap-corp.someUrl.abc",
        midRestUrl: String = "https://midrest.someUrl.abc",
        midSkRestUrl: String = "https://midskrest.someUrl.abc",
        sidV2RestUrl: String = "https://sidv2.someUrl.abc",
        sidV2SkRestUrl: String = "https://sidv2skrest.someUrl.abc",
        certBundle: [String] = ["certBundle1", "certBundle2"],
        ldapCerts: [String] = ["ldapCert1", "ldapCert2"],
        configurationLastUpdateCheckDate: Date? = Calendar(
            identifier: .gregorian)
            .date(from: DateComponents(year: 2025, month: 9, day: 2, hour: 15, minute: 22, second: 28)
        ),
        configurationUpdateDate: Date? = Calendar(
            identifier: .gregorian)
            .date(from: DateComponents(year: 2025, month: 9, day: 2, hour: 15, minute: 22, second: 28)
        ),
        cdoc2DefaultKeyserver: String = "https://cdoc2DefaultKeyserver.someUrl.abc",
        cdoc2UseKeyserver: Bool = false,
        cdoc2ConfUUID: String = "00000000-0000-0000-0000-000000000000",
        cdoc2ConfName: String = "RIA",
        cdoc2ConfPostUrl: String = "https://cdoc2.example.ee:8443",
        cdoc2ConfFetchUrl: String = "https://cdoc2.example.ee:8444"
    ) throws -> ConfigurationProvider {
        let metaInf = ConfigurationProvider.MetaInf(
            url: metaInfUrl,
            date: metaInfDate,
            serial: metaInfSerial,
            version: metaInfVersion
        )

        let sivaURL = try TestFileUtil.getURL(string: sivaUrl)
        let tslURL = try TestFileUtil.getURL(string: tslUrl)
        let tsaURL = try TestFileUtil.getURL(string: tsaUrl)

        let ldapPersonURLs: [URL] = ldapPersonUrls.compactMap {
                try? TestFileUtil.getURL(string: $0)
        }

        let ldapPersonURL = try TestFileUtil.getURL(string: ldapPersonUrl)
        let ldapCorpURL = try TestFileUtil.getURL(string: ldapCorpUrl)
        let midRestURL = try TestFileUtil.getURL(string: midRestUrl)
        let midSkRestURL = try TestFileUtil.getURL(string: midSkRestUrl)
        let sidV2RestURL = try TestFileUtil.getURL(string: sidV2RestUrl)
        let sidV2SkRestURL = try TestFileUtil.getURL(string: sidV2SkRestUrl)

        let tslCertsData: [Data] = tslCerts.compactMap { $0.data(using: .utf8) }
        let certBundleData: [Data] = certBundle.compactMap { $0.data(using: .utf8) }
        let ldapCertsData: [Data] = ldapCerts.compactMap { $0.data(using: .utf8) }

        let cdoc2Conf = try setupCDOC2Conf(
            cdoc2ConfUUID: cdoc2ConfUUID,
            cdoc2ConfName: cdoc2ConfName,
            cdoc2ConfPostUrl: cdoc2ConfPostUrl,
            cdoc2ConfFetchUrl: cdoc2ConfFetchUrl
        )

        return ConfigurationProvider(
            metaInf: metaInf,
            sivaUrl: sivaURL,
            tslUrl: tslURL,
            tslCerts: tslCertsData,
            tsaUrl: tsaURL,
            ocspIssuers: ocspIssuers,
            ldapPersonUrls: ldapPersonURLs,
            ldapPersonUrl: ldapPersonURL,
            ldapCorpUrl: ldapCorpURL,
            midRestUrl: midRestURL,
            midSkRestUrl: midSkRestURL,
            sidV2RestUrl: sidV2RestURL,
            sidV2SkRestUrl: sidV2SkRestURL,
            certBundle: certBundleData,
            ldapCerts: ldapCertsData,
            configurationLastUpdateCheckDate: configurationLastUpdateCheckDate,
            configurationUpdateDate: configurationUpdateDate,
            cdoc2DefaultKeyserver: cdoc2DefaultKeyserver,
            cdoc2UseKeyserver: cdoc2UseKeyserver,
            cdoc2Conf: cdoc2Conf
        )
    }

    private static func setupCDOC2Conf(
        cdoc2ConfUUID: String,
        cdoc2ConfName: String,
        cdoc2ConfPostUrl: String,
        cdoc2ConfFetchUrl: String
    ) throws -> [String: ConfigurationProvider.CDOC2Conf] {
        let cdoc2ConfPostURL = try TestFileUtil.getURL(string: cdoc2ConfPostUrl)
        let cdoc2ConfFetchURL = try TestFileUtil.getURL(string: cdoc2ConfFetchUrl)

        return [
            cdoc2ConfUUID: ConfigurationProvider.CDOC2Conf(
                name: cdoc2ConfName,
                postURL: cdoc2ConfPostURL,
                fetchURL: cdoc2ConfFetchURL
            )
        ]
    }
}
