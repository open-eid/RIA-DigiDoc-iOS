// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing

@testable import UtilsLib

struct SystemUtilTests {

    @Test
    func getOSVersion_success() {
        let osVersion = SystemUtil.getOSVersion()

        #expect(!osVersion.isEmpty)

        // Accepts number.number.number i.e "18.6.0"
        if let regex = try? NSRegularExpression(pattern: #"^\d+\.\d+\.\d+$"#) {
            let range = NSRange(
                osVersion.startIndex..<osVersion.endIndex,
                in: osVersion
            )
            let match = regex.firstMatch(in: osVersion, options: [], range: range)

            #expect(match != nil)
        }
    }

    @Test
    func getDeviceModelIdentifier_isNonEmptyAndLowercased() {
        let model = SystemUtil.getDeviceModelIdentifier()

        #expect(!model.isEmpty)
        #expect(model == model.lowercased())
        #expect(!model.contains(" "))
        #expect(!model.contains("\0"))
    }

    @Test
    func getDeviceModelIdentifier_matchesSimulatorEnvironmentWhenPresent() {
        guard let simulatorModel = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] else {
            return
        }

        #expect(SystemUtil.getDeviceModelIdentifier() == simulatorModel.lowercased())
    }
}
