// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

// MARK: - Shared JSON helpers

protocol JSONCodable: Codable {}

extension JSONCodable {
    /// Decode from raw JSON Data
    static func from(jsonData: Data, decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        try decoder.decode(Self.self, from: jsonData)
    }

    /// Encode to JSON Data
    func toJSONData(pretty: Bool = false, encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        return try encoder.encode(self)
    }
}
