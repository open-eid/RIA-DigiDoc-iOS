import Foundation

extension CharacterSet {
    static var extraSymbols: CharacterSet {
        var symbolsSet = CharacterSet()
        symbolsSet.insert(charactersIn: "½@%:^?[]'\"”’{}#&`\\~«»/´")
        let rtlChars = ["\u{200E}", "\u{200F}", "\u{202E}", "\u{202A}", "\u{202B}"]
        for char in rtlChars {
            symbolsSet.insert(charactersIn: char)
        }
        return symbolsSet
    }
}
