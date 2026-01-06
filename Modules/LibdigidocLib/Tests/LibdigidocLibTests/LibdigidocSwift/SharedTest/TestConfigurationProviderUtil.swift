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

import ConfigLib
import Foundation
import CommonsTestShared

public struct TestConfigurationProviderUtil {

    public init() {}

    public static func getConfigurationProvider() throws -> ConfigurationProvider {
        let sivaUrl = try TestFileUtil.getURL(string: "https://siva.example.abc")
        let tslUrl = try TestFileUtil.getURL(string: "https://tsl.example.abc")
        let tsaUrl = try TestFileUtil.getURL(string: "https://tsa.example.abc")
        let ldapPersonUrl = try TestFileUtil.getURL(string: "https://ldapPerson.example.abc")
        let ldapCorpUrl = try TestFileUtil.getURL(string: "https://ldapCorp.example.abc")
        let midRestUrl = try TestFileUtil.getURL(string: "https://midRest.example.abc")
        let midSkRestUrl = try TestFileUtil.getURL(string: "https://midSkRest.example.abc")
        let sidV2RestUrl = try TestFileUtil.getURL(string: "https://sidv2Rest.example.abc")
        let sidV2SkRestUrl = try TestFileUtil.getURL(string: "https://sidv2SkRest.example.abc")
        let cdoc2ConfRiaPostUrl = try TestFileUtil.getURL(string: "https://cdoc2.example.ee:8443")
        let cdoc2ConfRiaFetchUrl = try TestFileUtil.getURL(string: "https://cdoc2.example.ee:8444")

        return ConfigurationProvider(
            metaInf: ConfigurationProvider.MetaInf.init(
                url: "https://metaInfUrl.example.abc",
                date: Date().ISO8601Format(),
                serial: 100,
                version: 123
            ),
            sivaUrl: sivaUrl,
            tslUrl: tslUrl,
            tslCerts: [],
            tsaUrl: tsaUrl,
            ldapPersonUrls: [],
            ldapPersonUrl: ldapPersonUrl,
            ldapCorpUrl: ldapCorpUrl,
            midRestUrl: midRestUrl,
            midSkRestUrl: midSkRestUrl,
            sidV2RestUrl: sidV2RestUrl,
            sidV2SkRestUrl: sidV2SkRestUrl,
            certBundle: [],
            ldapCerts: [],
            configurationLastUpdateCheckDate: Date(),
            configurationUpdateDate: Date(),
            cdoc2Default: false,
            cdoc2DefaultKeyserver: "https://cdoc2DefaultKeyserver.example.abc",
            cdoc2UseKeyserver: false,
            cdoc2Conf: [
                "00000000-0000-0000-0000-000000000000": ConfigurationProvider.CDOC2Conf.init(
                    name: "RIA",
                    postURL: cdoc2ConfRiaPostUrl,
                    fetchURL: cdoc2ConfRiaFetchUrl
                )
            ],
        )
    }
}
