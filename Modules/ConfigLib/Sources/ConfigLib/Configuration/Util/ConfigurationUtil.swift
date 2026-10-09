// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

struct ConfigurationUtil {

    static func isSerialNewerThanCached(cachedSerial: Int?, newSerial: Int) -> Bool {
        guard let cachedSerial = cachedSerial else {
            return true
        }
        return newSerial > cachedSerial
    }

    static func isBase64(encoded: String) -> Bool {
        guard !encoded.isEmpty, let decodedData = Data(base64Encoded: encoded) else {
            return false
        }

        return encoded == decodedData.base64EncodedString()
    }

    static func isVersion(_ version: String, lowerThan otherVersion: String) -> Bool {
        guard let components = versionComponents(version),
              let otherComponents = versionComponents(otherVersion) else {
            return false
        }

        let count = max(components.count, otherComponents.count)
        let padded = components + Array(repeating: 0, count: count - components.count)
        let otherPadded = otherComponents + Array(repeating: 0, count: count - otherComponents.count)

        return padded.lexicographicallyPrecedes(otherPadded)
    }

    private static func versionComponents(_ version: String) -> [Int]? {
        let parts = version
            .trimmingCharacters(in: .whitespaces)
            .split(separator: ".", omittingEmptySubsequences: false)
        let components = parts.compactMap { part in
            part.allSatisfy({ $0.isASCII && $0.isNumber }) ? Int(part) : nil
        }
        return components.count == parts.count ? components : nil
    }
}
