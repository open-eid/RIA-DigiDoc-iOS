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
import Security

// MARK: - WebEidSignRequest

struct WebEidSignRequest: Codable, Equatable, Sendable {

    let responseUri: String
    let origin: String
    let signingCertificate: SecCertificate
    let hash: String?
    let hashFunction: String?
    let personalData: WebEidPersonalData?

    enum CodingKeys: String, CodingKey {
        case responseUri
        case origin
        case signingCertificate
        case hash
        case hashFunction
        case personalData
    }

    init(
        responseUri: String,
        origin: String,
        signingCertificate: SecCertificate,
        hash: String?,
        hashFunction: String?,
        personalData: WebEidPersonalData?
    ) {
        self.responseUri = responseUri
        self.origin = origin
        self.signingCertificate = signingCertificate
        self.hash = hash
        self.hashFunction = hashFunction
        self.personalData = personalData
    }

    // MARK: - Codable

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        responseUri = try container.decode(String.self, forKey: .responseUri)
        origin = try container.decode(String.self, forKey: .origin)

        let certBase64 = try container.decode(String.self, forKey: .signingCertificate)
        guard let certData = Data(base64Encoded: certBase64),
              let cert = SecCertificateCreateWithData(nil, certData as CFData) else {
            throw DecodingError.dataCorruptedError(
                forKey: .signingCertificate,
                in: container,
                debugDescription: "Invalid Base64 X.509 certificate"
            )
        }
        signingCertificate = cert

        hash = try container.decodeIfPresent(String.self, forKey: .hash)
        hashFunction = try container.decodeIfPresent(String.self, forKey: .hashFunction)
        personalData = try container.decodeIfPresent(WebEidPersonalData.self, forKey: .personalData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(responseUri, forKey: .responseUri)
        try container.encode(origin, forKey: .origin)

        let certData = SecCertificateCopyData(signingCertificate) as Data
        try container.encode(certData.base64EncodedString(), forKey: .signingCertificate)

        try container.encodeIfPresent(hash, forKey: .hash)
        try container.encodeIfPresent(hashFunction, forKey: .hashFunction)
        try container.encodeIfPresent(personalData, forKey: .personalData)
    }
}

// MARK: - Convenience Helpers

extension WebEidSignRequest {

    /// Decode from raw JSON Data
    static func from(jsonData: Data) throws -> WebEidSignRequest {
        try JSONDecoder().decode(WebEidSignRequest.self, from: jsonData)
    }

    /// Encode to JSON Data
    func toJSONData(pretty: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        return try encoder.encode(self)
    }

    /// Extract public key from certificate
    var publicKey: SecKey? {
        SecCertificateCopyKey(signingCertificate)
    }
}

