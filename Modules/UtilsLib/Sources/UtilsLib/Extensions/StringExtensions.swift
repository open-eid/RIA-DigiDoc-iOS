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
        var cleanName = self
            .components(separatedBy: CharacterSet.forbiddenInFileName)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .precomposedStringWithCanonicalMapping
            .truncatedFileName(maxBytes: Constants.File.MaxNameBytes)

        while let first = cleanName.first, String.leadingDotCharacters.contains(first) {
            cleanName.removeFirst()
            if cleanName.isEmpty {
                cleanName = "_"
            }
        }

        return cleanName.isEmpty ? nil : cleanName
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
