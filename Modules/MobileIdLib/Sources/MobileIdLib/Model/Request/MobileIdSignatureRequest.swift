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

public struct MobileIdSignatureRequest: Sendable, Encodable, CustomStringConvertible {
    let certificateRequest: MobileIdCertificateRequest?
    let hash: String?
    let hashType: String?
    let language: String?
    let displayText: String?
    let displayTextFormat: String?

    public var description: String {
        return """
        MobileIdSignatureRequest(
            relyingPartyName: \(certificateRequest?.relyingPartyName ?? "-"),
            relyingPartyUUID: \(certificateRequest?.relyingPartyUUID ?? "-"),
            phoneNumber: \(certificateRequest?.phoneNumber ?? "-"),
            nationalIdentityNumber: \(certificateRequest?.nationalIdentityNumber ?? "-"),
            hash: \(hash ?? "-"),
            hashType: \(hashType ?? "-"),
            language: \(language ?? "-"),
            displayText: \(displayText ?? "-"),
            displayTextFormat: \(displayTextFormat ?? "-")
        )
        """
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hash, forKey: .hash)
        try container.encodeIfPresent(hashType, forKey: .hashType)
        try container.encodeIfPresent(language, forKey: .language)
        try container.encodeIfPresent(displayText, forKey: .displayText)
        try container.encodeIfPresent(displayTextFormat, forKey: .displayTextFormat)

        if let certificateRequest = certificateRequest {
            try certificateRequest.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case hash, hashType, language, displayText, displayTextFormat
    }
}
