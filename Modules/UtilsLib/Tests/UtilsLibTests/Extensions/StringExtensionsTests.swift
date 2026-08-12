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
import CommonsLib
@testable import UtilsLib

class StringSanitizationTests {

    @Test(arguments: [
        ("O&U report #1 (100%) @2026.pdf", "O&U report #1 (100%) @2026.pdf"),
        ("t€4t.pdf", "t€4t.pdf"),
        ("emoji😀.pdf", "emoji😀.pdf"),
        ("team\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F466}.pdf", "team\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F466}.pdf"),
        ("a+b=c~d^e.txt", "a+b=c~d^e.txt"),
        ("test[1]{2}.txt", "test[1]{2}.txt"),
        ("it's a ½ share.txt", "it's a ½ share.txt"),
        ("Test∑∞©®←→Data", "Test∑∞©®←→Data"),
        (".test", ".test"),
        ("v1..2 test.zip", "v1..2 test.zip")
    ])
    func sanitized_keepsCharactersThatAreLegalInAFileName(input: String, expected: String) {
        #expect(expected == input.sanitized())
    }

    @Test(arguments: [
        ("../../etc/test", "....etctest"),
        ("..\\..\\test", "....test"),
        ("a/b.txt", "ab.txt")
    ])
    func sanitized_removesPathSeparatorsSoNameStaysOneComponent(input: String, expected: String) {
        let sanitized = input.sanitized()

        #expect(expected == sanitized)
        #expect(!sanitized.contains("/"))
        #expect(!sanitized.contains("\\"))
    }

    @Test(arguments: [".", "..", "...."])
    func sanitized_replacesDirectoryReferencesWithDefaultName(input: String) {
        #expect(Constants.Container.DefaultName == input.sanitized())
    }

    @Test
    func sanitized_removesControlAndFormatCharacters() {
        let input = "a\u{0000}b\u{0001}c\u{007F}d\u{202E}e\u{200B}f\u{FEFF}g\u{2066}h"

        #expect("abcdefgh" == input.sanitized())
    }

    @Test(arguments: ["<", ">", ":", "\"", "|", "?", "*"])
    func sanitized_removesCharactersReservedForInterchange(character: String) {
        #expect("ab.txt" == "a\(character)b.txt".sanitized())
    }

    @Test
    func sanitized_returnsDefaultNameWhenNothingIsLeft() {
        #expect(Constants.Container.DefaultName == "".sanitized())
        #expect(Constants.Container.DefaultName == "///\\\\\\".sanitized())
    }

    @Test
    func uniqueFileName_disambiguatesWithinABatchOnly() {
        var taken: Set<String> = []

        #expect("a.txt".uniqueFileName(taken: &taken) == "a.txt")
        #expect("a.txt".uniqueFileName(taken: &taken) == "a (1).txt")
        #expect("a.txt".uniqueFileName(taken: &taken) == "a (2).txt")

        var fresh: Set<String> = []
        #expect("a.txt".uniqueFileName(taken: &fresh) == "a.txt")
    }

    @Test
    func uniqueFileName_keepsTheExtensionAndHandlesNamesWithout() {
        var taken: Set<String> = []

        #expect("report".uniqueFileName(taken: &taken) == "report")
        #expect("report".uniqueFileName(taken: &taken) == "report (1)")
        #expect("a.tar.gz".uniqueFileName(taken: &taken) == "a.tar.gz")
        #expect("a.tar.gz".uniqueFileName(taken: &taken) == "a.tar (1).gz")
    }

    @Test
    func sanitized_removesWhitespaceAndNewlines() {
        let input = " Test  \n Data  \n  "
        let expected = "Test   Data"

        #expect(expected == input.sanitized())
    }

    @Test
    func sanitized_normalizesToPrecomposedFormSoEquivalentNamesMatch() {
        let decomposed = "teste\u{0301}.txt"
        let precomposed = "test\u{00E9}.txt"

        #expect(precomposed == decomposed.sanitized())
        #expect(decomposed.sanitized() == precomposed.sanitized())
    }

    @Test
    func sanitized_truncatesLongNameKeepingExtension() {
        let input = String(repeating: "a", count: 500) + ".pdf"

        let sanitized = input.sanitized()

        #expect(sanitized.utf8.count <= Constants.File.MaxNameBytes)
        #expect(sanitized.hasSuffix(".pdf"))
    }

    @Test
    func sanitized_truncatesOnCharacterBoundariesSoNoReplacementCharacterAppears() {
        let input = String(repeating: "ä", count: 300) + ".pdf"

        let sanitized = input.sanitized()

        #expect(sanitized.utf8.count <= Constants.File.MaxNameBytes)
        #expect(!sanitized.contains("\u{FFFD}"))
    }

    @Test
    func sanitized_keepsALongEndingWhileItStillFitsUnderTheCap() {
        let input = String(repeating: "a", count: 300) + "." + String(repeating: "b", count: 100)

        let sanitized = input.sanitized()

        #expect(sanitized.utf8.count <= Constants.File.MaxNameBytes)
        #expect(sanitized.hasSuffix("." + String(repeating: "b", count: 100)))
    }

    @Test
    func sanitized_dropsAnEndingTooLongToLeaveRoomForAName() {
        let input = String(repeating: "a", count: 300) + "." + String(repeating: "b", count: 500)

        let sanitized = input.sanitized()

        #expect(sanitized.utf8.count <= Constants.File.MaxNameBytes)
        #expect(!sanitized.contains("b"))
    }

    @Test
    func getURLFromText_successWithSingleURL() throws {
        let input = "Additional information: https://example.com"
        let attributed = input.getURLFromText()

        #expect(attributed != nil)
        let range = attributed?.range(of: "https://example.com")
        #expect(range != nil)

        if let range {
            #expect(attributed?[range].link == URL(string: "https://example.com"))
            #expect(attributed?[range].foregroundColor == .link)
            #expect(attributed?[range].underlineStyle == .single)
        }
    }

    @Test
    func getURLFromText_successWithMultipleURLs() throws {
        let input = "Links: https://test1.example.com and https://test2.example.com"
        let attributed = input.getURLFromText()

        #expect(attributed != nil)

        let ranges = [
            attributed?.range(of: "https://test1.example.com"),
            attributed?.range(of: "https://test2.example.com")
        ]

        for range in ranges {
            #expect(range != nil)
            if let range {
                let urlString = String(attributed?[range].characters ?? AttributedString.CharacterView())
                #expect(attributed?[range].link == URL(string: urlString))
            }
        }
    }

    @Test(
        "getURLFromText - return original string when no valid links",
        arguments: ["Test text", "http:::/bad_url", ""]
    )
    func getURLFromText_returnOriginalStringWhenNoLinks(input: String) throws {
        let attributed = input.getURLFromText()
        #expect(attributed != nil)
        #expect(attributed == AttributedString(input))

        let links = attributed?.runs.filter { $0.link != nil } ?? []
        #expect(links.count == 0)
    }
}
