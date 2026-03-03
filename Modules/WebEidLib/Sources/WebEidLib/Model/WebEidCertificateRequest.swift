/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

// MARK: - WebEidCertificateRequest

struct WebEidCertificateRequest: Codable, Equatable, Sendable {

    let responseUri: String
    let origin: String

    enum CodingKeys: String, CodingKey {
        case responseUri
        case origin
    }
}

// MARK: - Convenience Helpers

extension WebEidCertificateRequest {

    /// Decode from raw JSON Data
    static func from(jsonData: Data) throws -> WebEidCertificateRequest {
        try JSONDecoder().decode(WebEidCertificateRequest.self, from: jsonData)
    }

    /// Encode to JSON Data
    func toJSONData(pretty: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        return try encoder.encode(self)
    }

    /// Convenience computed URL (safe conversion)
    var responseURL: URL? {
        URL(string: responseUri)
    }
}

