import Foundation
import CommonsLib

extension String {
    public func sanitized() -> String {
        var forbidden = CharacterSet.illegalCharacters
            .union(.symbols)
            .union(.extraSymbols)
        forbidden.insert(charactersIn: "\n\r\t")

        var cleanName = self
            .components(separatedBy: forbidden)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        while cleanName.hasPrefix(".") {
            cleanName.removeFirst()
            if cleanName.isEmpty {
                cleanName = "_"
            }
        }

        return cleanName.isEmpty ? Constants.Container.DefaultName : cleanName
    }
}
