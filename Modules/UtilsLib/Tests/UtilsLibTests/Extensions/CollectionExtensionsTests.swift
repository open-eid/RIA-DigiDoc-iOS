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

class CollectionExtensionsTests {

    @Test
    func hexString_returnEmptyStringwithEmptyArray() {
        let input: [UInt8] = []
        let expectedOutput = ""

        #expect(expectedOutput == input.hexString)
    }

    @Test
    func hexString_successWithSingleByte() {
        let input: [UInt8] = [0x1F]
        let expectedOutput = "1F"

        #expect(expectedOutput == input.hexString)
    }

    @Test
    func hexString_successWithMultipleBytes() {
        let input: [UInt8] = [0x00, 0xAB, 0x3C, 0xFF]
        let expectedOutput = "00 AB 3C FF"

        #expect(expectedOutput == input.hexString)
    }
}
