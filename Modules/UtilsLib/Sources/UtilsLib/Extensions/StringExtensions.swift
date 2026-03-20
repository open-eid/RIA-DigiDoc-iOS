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
