// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

// MARK: - WebEidCertificateRequest

public struct WebEidCertificateRequest: JSONCodable, Equatable, Sendable {

    public let responseUri: String
    public let origin: String

    public init(
        responseUri: String,
        origin: String
    ) {
        self.responseUri = responseUri
        self.origin = origin
    }

    enum CodingKeys: String, CodingKey {
        case responseUri
        case origin
    }
}

// MARK: - Convenience Helpers

extension WebEidCertificateRequest {
    /// Convenience computed URL (safe conversion)
    var responseURL: URL? {
        URL(string: responseUri)
    }
}
