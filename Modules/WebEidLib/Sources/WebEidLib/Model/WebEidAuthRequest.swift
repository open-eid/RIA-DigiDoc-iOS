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

struct WebEidAuthRequest: Codable, Equatable, Sendable {
    let challenge: String
    let loginUri: String
    let getSigningCertificate: Bool
    let origin: String

    enum CodingKeys: String, CodingKey {
        case challenge
        case loginUri
        case getSigningCertificate
        case origin
    }
}

/// Convenience helpers (to parse from incoming JSON)
extension WebEidAuthRequest {
    static func from(jsonData: Data) throws -> WebEidAuthRequest {
        try JSONDecoder().decode(WebEidAuthRequest.self, from: jsonData)
    }

    func toJSONData(pretty: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        if pretty { encoder.outputFormatting = [.prettyPrinted, .sortedKeys] }
        return try encoder.encode(self)
    }
}
