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
import Testing

@testable import UtilsLib

struct UserAgentUtilTests {

    @Test(
        "User-Agent follows schema structure",
        arguments: [
            (UserAgentDiagnostics.none, "en"),
            (UserAgentDiagnostics.devices, "en"),
            (UserAgentDiagnostics.nfc, "en"),
            (UserAgentDiagnostics.none, "et"),
            (UserAgentDiagnostics.devices, "et"),
            (UserAgentDiagnostics.nfc, "et")
        ]
    )
    func userAgent_followsSchemaStructure(diagnostics: UserAgentDiagnostics, language: String) throws {
        let userAgentUtil = UserAgentUtil()

        let userAgent = userAgentUtil.userAgent(diagnostics: diagnostics, language: language)

        #expect(userAgent.starts(with: "APP riadigidoc/"))

        let block = try #require(metadataBlock(of: userAgent), "Expected a parenthesized metadata block")

        let identifier = String(userAgent.prefix(while: { $0 != "(" })).trimmingCharacters(in: .whitespaces)
        #expect(identifier.hasPrefix("APP riadigidoc/"))
        #expect(identifier.count > "APP riadigidoc/".count, "Expected a version after the identifier")

        #expect(block.contains("schema=1"))
        #expect(block.contains("lang=\(language)"))

        let osIsIOS = block.contains("os=iOS ")
        let osIsIPadOS = block.contains("os=iPadOS ")
        #expect(osIsIOS || osIsIPadOS)

        let isMobile = block.contains("devicetype=mobile/")
        let isTablet = block.contains("devicetype=tablet/")
        #expect(isMobile || isTablet)

        #expect(osIsIPadOS == isTablet)
    }

    @Test
    func userAgent_mandatoryFieldsAppearInOrder() throws {
        let userAgentUtil = UserAgentUtil()

        let block = try #require(metadataBlock(of: userAgentUtil.userAgent(diagnostics: .none, language: "et")))

        let schemaIndex = try #require(block.range(of: "schema=")).lowerBound
        let osIndex = try #require(block.range(of: "os=")).lowerBound
        let langIndex = try #require(block.range(of: "lang=")).lowerBound
        let deviceTypeIndex = try #require(block.range(of: "devicetype=")).lowerBound

        #expect(schemaIndex < osIndex)
        #expect(osIndex < langIndex)
        #expect(langIndex < deviceTypeIndex)
    }

    @Test
    func userAgent_fieldsSeparatedBySemicolon() throws {
        let userAgentUtil = UserAgentUtil()

        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: "en")

        #expect(userAgent.filter { $0 == "(" }.count == 1)
        #expect(userAgent.filter { $0 == ")" }.count == 1)

        let block = try #require(metadataBlock(of: userAgent))
        let fields = block.components(separatedBy: "; ")
        #expect(fields.count == 4)
        #expect(fields[0] == "schema=1")
        #expect(fields[1].hasPrefix("os="))
        #expect(fields[2].hasPrefix("lang="))
        #expect(fields[3].hasPrefix("devicetype="))
    }

    @Test(
        ".none omits devices and nfc fields",
        arguments: ["en", "et"]
    )
    func userAgent_noneDiagnosticsNoDevicesAndNFCFields(language: String) {
        let userAgentUtil = UserAgentUtil()

        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: language)

        #expect(!userAgent.contains("nfc="))
        #expect(!userAgent.contains("devices="))
    }

    @Test(
        ".nfc diagnostics appends nfc and shows no devices",
        arguments: ["en", "et"]
    )
    func userAgent_nfcDiagnostics(language: String) {
        let userAgentUtil = UserAgentUtil()

        let userAgent = userAgentUtil.userAgent(diagnostics: .nfc, language: language)

        #expect(userAgent.contains("; nfc=true"))
        #expect(!userAgent.contains("devices="))
        #expect(userAgent.hasSuffix("nfc=true)"))
    }

    @Test
    func userAgent_devicesDoesntShowNFC() throws {
        let userAgentUtil = UserAgentUtil()

        let userAgent = userAgentUtil.userAgent(diagnostics: .devices, language: "en")

        #expect(!userAgent.contains("nfc="))

        let block = try #require(metadataBlock(of: userAgent))
        if let devicesRange = block.range(of: "devices=") {
            let deviceTypeIndex = try #require(block.range(of: "devicetype=")).lowerBound
            #expect(deviceTypeIndex < devicesRange.lowerBound)
        }
    }

    @Test
    func userAgent_prependsLibdigidocppPrefixWhenVersionProvided() {
        let userAgentUtil = UserAgentUtil(libdigidocppVersion: "4.3.0.1910")

        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: "et")

        #expect(userAgent.hasPrefix("LIB libdigidocpp/4.3.0.1910 ("))
        #expect(userAgent.contains(") APP riadigidoc/"))
        #expect(userAgent.hasSuffix(")"))
    }

    @Test
    func userAgent_libdigidocppPrefixUsesKnownArchitecture() {
        let userAgentUtil = UserAgentUtil(libdigidocppVersion: "4.3.0.1910")

        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: "et")

        let knownArchitectures = ["arm64", "x86_64", "arm", "i386"]
        #expect(knownArchitectures.contains { userAgent.contains("(\($0)) APP ") })
    }

    @Test
    func userAgent_omitsLibdigidocppPrefixWhenVersionEmpty() {
        let userAgentUtil = UserAgentUtil()

        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: "en")

        #expect(!userAgent.contains("LIB libdigidocpp/"))
        #expect(userAgent.hasPrefix("APP riadigidoc/"))
    }

    @Test(
        "Delimiters, control characters and surrounding whitespace are stripped from fields",
        arguments: [
            ("e;n", "en"),
            ("e(n)", "en"),
            ("en\n", "en"),
            ("e\u{2028}n\u{2029}", "en"),
            ("  en  ", "en")
        ]
    )
    func userAgent_sanitizesFields(rawLanguage: String, expected: String) throws {
        let userAgent = UserAgentUtil().userAgent(diagnostics: .none, language: rawLanguage)

        let block = try #require(metadataBlock(of: userAgent))

        #expect(block.contains("lang=\(expected)"))
        #expect(block.components(separatedBy: "; ").count == 4)
    }

    @Test
    func appInfo_isTheAppPartWithoutLibOrAppTokens() {
        let appInfo = UserAgentUtil(libdigidocppVersion: "4.3.0.1910").appInfo(diagnostics: .none, language: "et")

        #expect(appInfo.hasPrefix("riadigidoc/"))
        #expect(!appInfo.contains("LIB libdigidocpp/"))
        #expect(!appInfo.hasPrefix("APP "))
        #expect(appInfo.contains("(schema=1;"))
    }

    @Test
    func appInfo_isIndependentOfLibdigidocppVersion() {
        let withVersion = UserAgentUtil(libdigidocppVersion: "4.3.0.1910").appInfo(diagnostics: .none, language: "en")
        let withoutVersion = UserAgentUtil().appInfo(diagnostics: .none, language: "en")

        #expect(withVersion == withoutVersion)
    }

    @Test
    func userAgent_wrapsAppInfoWithLibAndAppTokens() {
        let userAgentUtil = UserAgentUtil(libdigidocppVersion: "4.3.0.1910")

        let userAgent = userAgentUtil.userAgent(diagnostics: .none, language: "et")
        let appInfo = userAgentUtil.appInfo(diagnostics: .none, language: "et")

        #expect(userAgent.hasSuffix("APP \(appInfo)"))
    }

    private func metadataBlock(of userAgent: String) -> String? {
        guard let open = userAgent.lastIndex(of: "("),
              let close = userAgent.lastIndex(of: ")"),
              open < close else {
            return nil
        }
        return String(userAgent[open...close].dropFirst().dropLast())
    }
}
