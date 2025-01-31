import Foundation

extension String {
    public func sanitized() -> String {
        var text = self

        let characterSet: CharacterSet = CharacterSet.illegalCharacters
            .union(.symbols)
            .union(.extraSymbols)
            .union(.whitespacesAndNewlines)

        while text.hasPrefix(".") {
            if text.count > 1 {
                text.removeFirst()
            } else {
                text = text.replacingOccurrences(of: ".", with: "_")
            }
        }

        return text.components(separatedBy: characterSet).joined()
    }
}
