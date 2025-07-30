import Foundation
import OSLog
import CommonsLib

extension String {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "String extension")

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

    public func getURLFromText() -> AttributedString? {
        var attributedString = AttributedString(self)

        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self, range: NSRange(startIndex..., in: self))

            for match in matches {
                guard let url = match.url,
                      let attributedRange = Range(match.range, in: attributedString) else {
                    continue
                }

                attributedString[attributedRange].link = url
                attributedString[attributedRange].foregroundColor = .link
                attributedString[attributedRange].underlineStyle = .single
            }

            return attributedString
        } catch {
            return nil
        }
    }
}
