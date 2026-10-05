// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib

extension String {

    private static let leadingDotCharacters: Set<Character> = [".", "\u{2026}"]

    public func sanitized() -> String {
        return sanitizedOrNil() ?? Constants.Container.DefaultName
    }

    public func sanitizedOrNil() -> String? {
        var forbidden = CharacterSet.illegalCharacters
            .union(.symbols)
            .union(.extraSymbols)
        forbidden.insert(charactersIn: "\n\r\t")

        var cleanName = self
            .components(separatedBy: forbidden)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        while let first = cleanName.first, String.leadingDotCharacters.contains(first) {
            cleanName.removeFirst()
            if cleanName.isEmpty {
                cleanName = "_"
            }
        }

        return cleanName.isEmpty ? nil : cleanName
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
