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

public struct TestConfigurationProviderUtil {

    public init() {}

    public static func getConfigurationProvider() throws -> ConfigurationProvider {
        guard let sivaUrl = URL(string: "https://siva.example.abc") else {
            throw URLError(.badURL)
        }

        guard let tslUrl = URL(string: "https://tsl.example.abc") else {
            throw URLError(.badURL)
        }

        guard let tsaUrl = URL(string: "https://tsa.example.abc") else {
            throw URLError(.badURL)
        }

        guard let ldapPersonUrl = URL(string: "https://ldapPerson.example.abc") else {
            throw URLError(.badURL)
        }

        guard let ldapCorpUrl = URL(string: "https://ldapCorp.example.abc") else {
            throw URLError(.badURL)
        }

        guard let midRestUrl = URL(string: "https://midRest.example.abc") else {
            throw URLError(.badURL)
        }

        guard let midSkRestUrl = URL(string: "https://midSkRest.example.abc") else {
            throw URLError(.badURL)
        }

        guard let sidV2RestUrl = URL(string: "https://sidv2Rest.example.abc") else {
            throw URLError(.badURL)
        }

        guard let sidV2SkRestUrl = URL(string: "https://sidv2SkRest.example.abc") else {
            throw URLError(.badURL)
        }

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
            ocspIssuers: [:],
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
            cdoc2DefaultKeyserver: "https://cdoc2DefaultKeyserver.example.abc",
            cdoc2UseKeyserver: false,
            cdoc2Conf: [:],
        )
    }
}
