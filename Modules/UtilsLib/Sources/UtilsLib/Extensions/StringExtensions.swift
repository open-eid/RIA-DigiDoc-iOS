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
        let cleanName = self
            .components(separatedBy: CharacterSet.forbiddenInFileName)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .precomposedStringWithCanonicalMapping
            .truncatedFileName(maxBytes: Constants.File.MaxNameBytes)

        if cleanName.isEmpty || cleanName.allSatisfy({ $0 == "." }) {
            return Constants.Container.DefaultName
        }

        return cleanName
    }

    public func appendingIndex(_ index: Int) -> String {
        let base = (self as NSString).deletingPathExtension
        let ext = (self as NSString).pathExtension

        return ext.isEmpty ? "\(base) (\(index))" : "\(base) (\(index)).\(ext)"
    }

    public func uniqueFileName(taken: inout Set<String>) -> String {
        var candidate = self
        var counter = 1

        while taken.contains(candidate) {
            candidate = appendingIndex(counter)
            counter += 1
        }

        taken.insert(candidate)
        return candidate
    }

    public func truncatedFileName(maxBytes: Int) -> String {
        guard utf8.count > maxBytes else { return self }

        let suffix = (self as NSString).pathExtension
        let candidate = suffix.isEmpty ? "" : ".\(suffix)"
        let ext = candidate.utf8.count < maxBytes ? candidate : ""
        let base = ext.isEmpty ? self : (self as NSString).deletingPathExtension

        var truncated = ""
        var byteCount = ext.utf8.count
        for character in base {
            let size = String(character).utf8.count
            if byteCount + size > maxBytes { break }
            truncated.append(character)
            byteCount += size
        }

        return truncated + ext
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
