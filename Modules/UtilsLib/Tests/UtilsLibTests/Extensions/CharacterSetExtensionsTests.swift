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

class CharacterSetExtensionsTests {

    @Test(arguments: ["/", "\\", "<", ">", ":", "\"", "|", "?", "*"])
    func forbiddenInFileName_containsPathSeparatorsAndReservedCharacters(character: String) throws {
        let scalar = try #require(character.unicodeScalars.first)

        #expect(CharacterSet.forbiddenInFileName.contains(scalar))
    }

    @Test(arguments: [
        "\u{0000}", "\u{0001}", "\u{0009}", "\u{000A}", "\u{000D}", "\u{007F}", "\u{0085}",
        "\u{200B}", "\u{200E}", "\u{200F}", "\u{202A}", "\u{202B}", "\u{202C}", "\u{202E}",
        "\u{2060}", "\u{2066}", "\u{FEFF}", "\u{061C}"
    ])
    func forbiddenInFileName_containsControlAndFormatCharacters(character: String) throws {
        let scalar = try #require(character.unicodeScalars.first)

        #expect(CharacterSet.forbiddenInFileName.contains(scalar))
    }

    @Test
    func forbiddenInFileName_allowsCharactersThatAreLegalInAFileName() {
        let allowed = "ABCabc019 #&+@%$=~^[]{}'.,;()!-_½«»´€äöüõ😀"

        for character in allowed {
            guard let scalar = character.unicodeScalars.first else {
                Issue.record("Unable to get Unicode scalar for character \(character)")
                return
            }
            #expect(!CharacterSet.forbiddenInFileName.contains(scalar), "\(character) should be allowed")
        }
    }
}
