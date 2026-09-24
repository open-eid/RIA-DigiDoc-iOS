// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct MobileIdCertificateResponse: Sendable, Decodable, CustomStringConvertible {
    public let result: MobileIdCertificateResult?
    public let cert: String?
    public let time: String?
    public let traceId: String?

    public var description: String {
        return """
        MobileIdSignatureRequest(
            result: \(result?.rawValue ?? "-"),
            cert: \(cert ?? "-"),
            time: \(time ?? "-"),
            traceId: \(traceId ?? "-")
        )
        """
    }

    public init(
        result: MobileIdCertificateResult?,
        cert: String?,
        time: String?,
        traceId: String?
    ) {
        self.result = result
        self.cert = cert
        self.time = time
        self.traceId = traceId
    }
}

public enum MobileIdCertificateResult: String, Sendable, Decodable {
    // swiftlint:disable:next identifier_name
    case ok = "OK"
    case notFound = "NOT_FOUND"
    case notActive = "NOT_ACTIVE"
}
