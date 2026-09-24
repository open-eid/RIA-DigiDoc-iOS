// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Security

// MARK: - WebEidSignRequest

public struct WebEidSignRequest: JSONCodable, Equatable, Sendable {

    public let responseUri: String
    public let origin: String
    public let signingCertificate: SecCertificate
    public let hash: String?
    public let hashFunction: String?
    public let personalData: WebEidPersonalData?

    enum CodingKeys: String, CodingKey {
        case responseUri
        case origin
        case signingCertificate
        case hash
        case hashFunction
        case personalData
    }

    public init(
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

    public init(from decoder: Decoder) throws {
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

    public func encode(to encoder: Encoder) throws {
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
    /// Extract public key from certificate
    var publicKey: SecKey? {
        SecCertificateCopyKey(signingCertificate)
    }
}
