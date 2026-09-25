// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
