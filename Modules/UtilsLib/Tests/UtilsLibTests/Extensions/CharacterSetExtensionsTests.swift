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

class CharacterSetExtensionsTests {

    @Test
    func extraSymbols_successCheckingCharacterSet() {
        let expectedCharacters = "½@%:^?[]'\"”’{}#&`\\~«»/´"
        let rtlChars = ["\u{200E}", "\u{200F}", "\u{202E}", "\u{202A}", "\u{202B}"]

        let extraSymbolsSet = CharacterSet.extraSymbols

        for char in expectedCharacters {
            guard let scalar = char.unicodeScalars.first else {
                Issue.record("Unable to get Unicode scalar for character \(char)")
                return
            }
            #expect(extraSymbolsSet.contains(scalar))
        }

        for rtlChar in rtlChars {
            guard let scalar = rtlChar.unicodeScalars.first else {
                Issue.record("Unable to get Unicode scalar for RTL character \(rtlChar)")
                return
            }
            #expect(extraSymbolsSet.contains(scalar))
        }
    }

    @Test
    func extraSymbols_checkCharacterSetDoesNotContainOtherCharacters() {
        let nonExpectedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let extraSymbolsSet = CharacterSet.extraSymbols

        for char in nonExpectedCharacters {
            guard let scalar = char.unicodeScalars.first else {
                Issue.record("Unable to get Unicode scalar for character \(char)")
                return
            }
            #expect(!extraSymbolsSet.contains(scalar))
        }
    }

    @Test
    func extraSymbols_checkCharacterSetIncludesSpecialEdgeCases() {
        let specialEdgeCases = ["½", "@", "”", "’", "\\", "~", "«", "»", "/"]
        let extraSymbolsSet = CharacterSet.extraSymbols

        for char in specialEdgeCases {
            guard let scalar = char.unicodeScalars.first else {
                Issue.record("Failed to get Unicode scalar for character \(char)")
                return
            }
            #expect(extraSymbolsSet.contains(scalar))
        }
    }

    @Test
    func extraSymbols_checkCharacterSetContainsRTLCharacters() {
        let rtlChars = ["\u{200E}", "\u{200F}", "\u{202E}", "\u{202A}", "\u{202B}"]
        let extraSymbolsSet = CharacterSet.extraSymbols

        #expect(rtlChars.contains { rtlChar in
            guard let scalar = rtlChar.unicodeScalars.first else { return false }
            return extraSymbolsSet.contains(scalar)
        })
    }

    @Test
    func extraSymbols_checkCharacterSetIsNotEmpty() {
        let extraSymbolsSet = CharacterSet.extraSymbols
        #expect(!extraSymbolsSet.isEmpty)
    }
}
