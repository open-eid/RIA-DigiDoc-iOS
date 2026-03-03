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
import UtilsLib

struct WebEidResponseUtil: Loggable {

    /// Returns JSON-like dictionary (easy to JSON-serialize).
    static func createErrorPayload(
        code: WebEidErrorCode,
        message: String
    ) -> [String: Any] {
        [
            "error": true,
            "code": String(describing: code),
            "message": message
        ]
    }

    /// Builds URL with Base64URL-encoded JSON payload placed into URL.fragment.
    static func createResponseURL(
        responseUri: String,
        payload: [String: Any]
    ) throws -> URL {

        guard var components = URLComponents(string: responseUri) else {
            throw WebEidResponseUtilError.invalidResponseURI
        }

        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
        let encodedPayload = base64URLEncodeNoPadding(jsonData)

        components.fragment = encodedPayload

        guard let url = components.url else {
            throw WebEidResponseUtilError.couldNotBuildURL
        }
        return url
    }

    // MARK: - Base64URL (URL_SAFE | NO_PADDING | NO_WRAP)

    private static func base64URLEncodeNoPadding(_ data: Data) -> String {
        let b64 = data.base64EncodedString() // standard Base64, no wraps by default
        // Convert to Base64URL + remove padding
        return b64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}


