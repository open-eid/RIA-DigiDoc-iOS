// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ConfigLibMocks
import Foundation
import Testing

@testable import ConfigLib

struct ConfigurationProviderTests {

    @Test
    func isAppVersionUnsupported_returnFalseWhenUnsupportedVersionIsMissing() throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider()

        #expect(!provider.isAppVersionUnsupported("0.0.1"))
    }

    @Test
    func isAppVersionUnsupported_returnTrueWhenAppVersionIsLower() throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider(unsupportedAppVersion: "3.2.1")

        #expect(provider.isAppVersionUnsupported("3.2.0.100"))
    }

    @Test
    func isAppVersionUnsupported_returnFalseWhenAppVersionIsEqualOrHigher() throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider(unsupportedAppVersion: "3.2.1")

        #expect(!provider.isAppVersionUnsupported("3.2.1.0"))
        #expect(!provider.isAppVersionUnsupported("3.3.0.1"))
    }

    @Test
    func decode_readsUnsupportedAppVersion() throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider(unsupportedAppVersion: "3.2.1")

        let decoded = try JSONDecoder().decode(ConfigurationProvider.self, from: JSONEncoder().encode(provider))

        #expect(decoded.unsupportedAppVersion == "3.2.1")
    }

    @Test
    func decode_returnNilUnsupportedAppVersionWhenKeyIsMissing() throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider()

        let data = try JSONEncoder().encode(provider)
        let json = try #require(String(data: data, encoding: .utf8))
        let decoded = try JSONDecoder().decode(ConfigurationProvider.self, from: data)

        #expect(!json.contains("RIADD-UNSUPPORTED"))
        #expect(decoded.unsupportedAppVersion == nil)
    }

    @Test(arguments: ["", "3.2.1-beta", "abc"])
    func isAppVersionUnsupported_returnFalseWhenUnsupportedVersionIsInvalid(unsupportedAppVersion: String) throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider(
            unsupportedAppVersion: unsupportedAppVersion
        )

        #expect(!provider.isAppVersionUnsupported("3.2.0.1"))
    }

    @Test
    func isAppVersionUnsupported_returnFalseWhenAppVersionIsUnknown() throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider(unsupportedAppVersion: "99.0.0")

        #expect(!provider.isAppVersionUnsupported("-.-"))
    }

    @Test
    func decode_ignoresNonStringUnsupportedAppVersion() throws {
        let provider = try TestConfigurationProvider.mockConfigurationProvider()
        var json = try #require(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(provider)) as? [String: Any]
        )
        json["RIADD-UNSUPPORTED"] = 3.3

        let decoded = try JSONDecoder().decode(
            ConfigurationProvider.self,
            from: JSONSerialization.data(withJSONObject: json)
        )

        #expect(decoded.unsupportedAppVersion == nil)
        #expect(decoded.sivaUrl == provider.sivaUrl)
    }
}
