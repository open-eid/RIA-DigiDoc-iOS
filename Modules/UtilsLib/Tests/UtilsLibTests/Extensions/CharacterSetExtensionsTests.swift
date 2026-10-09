// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
