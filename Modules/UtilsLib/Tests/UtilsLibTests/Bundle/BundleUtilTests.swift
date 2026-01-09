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
import Testing

@testable import UtilsLib

struct BundleUtilTests {

    @Test
    func getBundleIdentifier_success() {
        let expectedBundleIdentifier = "com.apple.dt.xctest.tool"

        let bundleIdentifier = BundleUtil.getBundleIdentifier()

        #expect(expectedBundleIdentifier == bundleIdentifier)
    }

    @Test
    func getBundleShortVersionString_success() {
        if let appBundle = Bundle(identifier: "ee.ria.digidoc") {
            let bundleShortVersionString = BundleUtil.getBundleShortVersionString(bundle: appBundle)

            #expect(!bundleShortVersionString.isEmpty)

            // Accepts number.number.number i.e "1.0.0"
            if let regex = try? NSRegularExpression(pattern: #"^\d+\.\d+\.\d+$"#) {
                let range = NSRange(
                    bundleShortVersionString.startIndex..<bundleShortVersionString.endIndex,
                    in: bundleShortVersionString
                )
                let match = regex.firstMatch(in: bundleShortVersionString, options: [], range: range)

                #expect(match != nil)
            }
        }
    }

    @Test
    func getBundleVersion_success() {
        if let appBundle = Bundle(identifier: "ee.ria.digidoc") {
            let bundleVersion = BundleUtil.getBundleVersion(bundle: appBundle)

            #expect(!bundleVersion.isEmpty)

            // Accepts numbers i.e "1", "42", "20250811"
            if let regex = try? NSRegularExpression(pattern: #"^\d+$"#) {
                let range = NSRange(bundleVersion.startIndex..<bundleVersion.endIndex, in: bundleVersion)
                let match = regex.firstMatch(in: bundleVersion, options: [], range: range)

                #expect(match != nil)
            }
        }
    }
}
