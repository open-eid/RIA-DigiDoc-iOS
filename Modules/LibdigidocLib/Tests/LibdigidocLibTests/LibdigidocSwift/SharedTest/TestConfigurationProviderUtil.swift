// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ConfigLib
import Foundation
import CommonsTestShared

public struct TestConfigurationProviderUtil {

    public init() {}

    public static func getConfigurationProvider() throws -> ConfigurationProvider {
        let sivaUrl = try TestFileUtil.getURL(string: "https://siva.example.invalid")
        let tslUrl = try TestFileUtil.getURL(string: "https://tsl.example.invalid")
        let tsaUrl = try TestFileUtil.getURL(string: "https://tsa.example.invalid")
        let ldapPersonUrl = try TestFileUtil.getURL(string: "https://ldapPerson.example.invalid")
        let ldapCorpUrl = try TestFileUtil.getURL(string: "https://ldapCorp.example.invalid")
        let midRestUrl = try TestFileUtil.getURL(string: "https://midRest.example.invalid")
        let midSkRestUrl = try TestFileUtil.getURL(string: "https://midSkRest.example.invalid")
        let sidV2RestUrl = try TestFileUtil.getURL(string: "https://sidv2Rest.example.invalid")
        let sidV2SkRestUrl = try TestFileUtil.getURL(string: "https://sidv2SkRest.example.invalid")
        let cdoc2ConfRiaPostUrl = try TestFileUtil.getURL(string: "https://cdoc2.example.invalid:8443")
        let cdoc2ConfRiaFetchUrl = try TestFileUtil.getURL(string: "https://cdoc2.example.invalid:8444")

        return ConfigurationProvider(
            metaInf: ConfigurationProvider.MetaInf.init(
                url: "https://metaInfUrl.example.invalid",
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
            cdoc2DefaultKeyserver: "https://cdoc2DefaultKeyserver.example.invalid",
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
