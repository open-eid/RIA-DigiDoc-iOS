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

public struct MobileIdSessionResponse: Sendable, Decodable, CustomStringConvertible {
    public let state: SessionResponseState?
    public let result: SessionResultCode?
    public let signature: MobileIdSessionSignatureResponse?
    public let cert: String?
    public let time: String?
    public let traceId: String?

    public var description: String {
        return """
        MobileIdSessionResponse(
            state: \(state?.rawValue ?? "-"),
            result: \(result?.rawValue ?? "-"),
            signature: \(signature?.description ?? "-"),
            cert: \(cert ?? "-"),
            time: \(time ?? "-"),
            traceId: \(traceId ?? "-")
        )
        """
    }
}

public struct MobileIdSessionSignatureResponse: Sendable, Decodable {
    public let value: Data?
    public let algorithm: String?

    public var description: String {
        return """
        MobileIdSessionSignatureResponse(
            value: \(value?.base64EncodedString() ?? ""),
            algorithm: \(algorithm ?? "")
        """
    }
}

public enum SessionResponseState: String, Sendable, Decodable {
    case running = "RUNNING"
    case complete = "COMPLETE"
}

public enum SessionResultCode: String, Sendable, Decodable {
    // swiftlint:disable:next identifier_name
    case ok = "OK"
    case timeout = "TIMEOUT"
    case notMidClient = "NOT_MID_CLIENT"
    case userCancelled = "USER_CANCELLED"
    case signatureHashMismatch = "SIGNATURE_HASH_MISMATCH"
    case phoneAbsent = "PHONE_ABSENT"
    case deliveryError = "DELIVERY_ERROR"
    case simError = "SIM_ERROR"
}
