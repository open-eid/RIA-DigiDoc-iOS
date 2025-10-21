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

class TextUtilTests {

    @Test
    func removeSlashes_successWithSingleBackslash() {
        let input = "Test\\Data"
        let expectedOutput = "TestData"

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_successWithMultipleBackslashes() {
        let input = "Text\\With\\Slashes"
        let expectedOutput = "TextWithSlashes"

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_successWithNoBackslashes() {
        let input = "WithoutBackslashes"
        let expectedOutput = "WithoutBackslashes"

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_returnEmptyStringWithEmptyStringInput() {
        let input = ""
        let expectedOutput = ""

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func removeSlashes_returnEmptyStringWithOnlyBackslashesInput() {
        let input = "\\\\\\"
        let expectedOutput = ""

        #expect(expectedOutput == TextUtil.removeSlashes(input))
    }

    @Test
    func formatSerialNumber_successWithColons() {
        let input = "AA:BB:CC:DD:EE"
        let expectedOutput = "AA BB CC DD EE"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_successWithLowercaseLettersAndColons() {
        let input = "aa:bb:cc:dd:ee"
        let expectedOutput = "AA BB CC DD EE"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_successWithoutColons() {
        let input = "AABBCCDDEE"
        let expectedOutput = "AABBCCDDEE"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_successWithMixedColonsAndSpaces() {
        let input = "AA:BB CC:DD"
        let expectedOutput = "AA BB CC DD"

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }

    @Test
    func formatSerialNumber_returnEmptyStringWithEmptyStringInput() {
        let input = ""
        let expectedOutput = ""

        #expect(expectedOutput == TextUtil.formatSerialNumber(input))
    }
}
