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
import CryptoKit
@testable import UtilsLib

class DigestExtensionsTests {

    @Test
    func hexString_suceessWithSHA256DigestAndDefaultSeparator() {
        let input = Data("Test Data!".utf8)

        let digest = SHA256.hash(data: input)

        let expectedOutput = digest.map { String(format: "%02X", $0) }.joined(separator: " ")

        #expect(expectedOutput == digest.hexString())
    }

    @Test
    func hexString_successWithSHA256DigestAndCustomSeparator() {
        let input = Data("Test Data!".utf8)

        let digest = SHA256.hash(data: input)

        let expectedOutput = digest.map { String(format: "%02X", $0) }.joined(separator: "-")

        #expect(expectedOutput == digest.hexString(separator: "-"))
    }

    @Test
    func hexString_successWithSHA256DigestEmptyStringSeparator() {
        let input = Data("Test Data!".utf8)

        let digest = SHA256.hash(data: input)

        let expectedOutput = digest.map { String(format: "%02X", $0) }.joined(separator: "")

        #expect(expectedOutput == digest.hexString(separator: ""))
    }
}
