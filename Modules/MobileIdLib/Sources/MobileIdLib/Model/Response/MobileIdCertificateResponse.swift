/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
