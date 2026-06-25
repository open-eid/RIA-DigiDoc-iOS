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
