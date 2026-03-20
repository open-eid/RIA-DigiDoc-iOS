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
        "User-Agent contains expected info",
        arguments: [
            (UserAgentDiagnostics.none, "en"),
            (UserAgentDiagnostics.devices, "en"),
            (UserAgentDiagnostics.nfc, "en"),
            (UserAgentDiagnostics.none, "ee"),
            (UserAgentDiagnostics.devices, "ee"),
            (UserAgentDiagnostics.nfc, "ee")
        ]
    )
    func userAgent_containsExpectedUserAgentInfo(diagnostics: UserAgentDiagnostics, language: String) {
        let userAgentUtil = UserAgentUtil()

        let userAgent = userAgentUtil.userAgent(diagnostics: diagnostics, language: language)

        #expect(userAgent.starts(with: "riadigidoc/"))
        #expect(userAgent.contains("(iOS "))
        #expect(userAgent.contains("Lang: \(language)"))

        switch diagnostics {
        case .none:
            #expect(!userAgent.contains("Devices:"))
            #expect(!userAgent.contains("NFC:"))

        case .devices:
            #expect(userAgent.contains("Devices:") || !userAgent.contains("Devices:"))
            #expect(!userAgent.contains("NFC:"))

        case .nfc:
            #expect(!userAgent.contains("Devices:"))
            #expect(userAgent.contains("NFC: true"))
        }
    }
}
