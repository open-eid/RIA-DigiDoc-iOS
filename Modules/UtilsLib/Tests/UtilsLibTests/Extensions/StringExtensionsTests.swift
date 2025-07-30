import Foundation
import Testing
import CommonsLib
@testable import UtilsLib

class StringSanitizationTests {

    @Test
    func sanitized_removesIllegalCharacters() {
        let input = "\u{FFFF}\u{FFFE}\u{1F600}"
        let expected = Constants.Container.DefaultName

        #expect(expected == input.sanitized())
    }

    @Test
    func sanitized_removesSymbols() {
        let symbols = "Test∑∞€©®←→Data"
        #expect(symbols.sanitized() == "TestData")
    }

    @Test
    func sanitized_extraSymbolsAndRTLCharacters() {
        let input = "½@%:^?[]'\"”’{}#&`\\~«»/´\u{200E}\u{200F}\u{202E}\u{202A}\u{202B}"
        let expected = Constants.Container.DefaultName

        #expect(expected == input.sanitized())
    }

    @Test
    func sanitized_removesWhitespaceAndNewlines() {
        let input = " Test  \n Data  \n  "
        let expected = "Test   Data"

        #expect(expected == input.sanitized())
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

    @Test("getURLFromText - return original string when no valid links", arguments: ["Test text", "http:::/bad_url", ""])
    func getURLFromText_returnOriginalStringWhenNoLinks(input: String) throws {
        let attributed = input.getURLFromText()
        #expect(attributed != nil)
        #expect(attributed == AttributedString(input))

        let links = attributed?.runs.filter { $0.link != nil } ?? []
        #expect(links.count == 0)
    }
}
