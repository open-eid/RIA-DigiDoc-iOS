// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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

    public init(
        state: SessionResponseState?,
        result: SessionResultCode?,
        signature: MobileIdSessionSignatureResponse?,
        cert: String?,
        time: String?,
        traceId: String?
    ) {
        self.state = state
        self.result = result
        self.signature = signature
        self.cert = cert
        self.time = time
        self.traceId = traceId
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

    public init(value: Data?, algorithm: String?) {
        self.value = value
        self.algorithm = algorithm
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
