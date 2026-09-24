// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import UtilsLib

public struct WebEidResponseUtil: Loggable {

    /// Returns JSON-like dictionary (easy to JSON-serialize).
    public static func createErrorPayload(
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
    public static func createResponseURL(
        responseUri: String,
        payload: [String: Any]
    ) throws -> URL {

        guard var components = URLComponents(string: responseUri) else {
            throw WebEidResponseUtilError.invalidResponseURI
        }

        guard components.scheme?.lowercased() == "https",
              let host = components.host, !host.isEmpty else {
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
            .replacing("+", with: "-")
            .replacing("/", with: "_")
            .replacing("=", with: "")
    }
}
