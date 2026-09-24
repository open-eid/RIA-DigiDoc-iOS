// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct WebEidAuthRequest: JSONCodable, Equatable, Sendable {
    public let challenge: String
    public let loginUri: String
    public let getSigningCertificate: Bool
    public let origin: String

    public init(
        challenge: String,
        loginUri: String,
        getSigningCertificate: Bool,
        origin: String
    ) {
        self.challenge = challenge
        self.loginUri = loginUri
        self.getSigningCertificate = getSigningCertificate
        self.origin = origin
    }

    enum CodingKeys: String, CodingKey {
        case challenge
        case loginUri
        case getSigningCertificate
        case origin
    }
}
