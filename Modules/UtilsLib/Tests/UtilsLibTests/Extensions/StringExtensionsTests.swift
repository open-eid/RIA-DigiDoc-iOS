import Foundation
import Testing
@testable import UtilsLib

class StringSanitizationTests {

    @Test
    func sanitized_removesIllegalCharacters() {
        let input = "\u{FFFF}\u{FFFE}\u{1F600}"
        let expected = ""

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
        let expected = ""

        #expect(expected == input.sanitized())
    }

    @Test
    func sanitized_removesWhitespaceAndNewlines() {
        let input = " Test  \n Data  \n  "
        let expected = "TestData"

        #expect(expected == input.sanitized())
    }
}
