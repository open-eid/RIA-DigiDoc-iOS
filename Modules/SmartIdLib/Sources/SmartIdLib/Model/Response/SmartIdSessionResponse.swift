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

public struct SmartIdSessionResponse: Sendable, Decodable, CustomStringConvertible {
    public let state: SessionResponseState
    public let result: SessionResult?
    public let signature: SmartIdSessionSignatureResponse?
    public let cert: SmartIdSessionCertResponse?

    public var description: String {
        return """
        SmartIdSessionResponse(
            state: \(state.rawValue),
            result: \(result?.description ?? "-"),
            signature: \(signature?.description ?? "-"),
            cert: \(cert?.description ?? "-")
        )
        """
    }

    public init(
        state: SessionResponseState,
        result: SessionResult?,
        signature: SmartIdSessionSignatureResponse?,
        cert: SmartIdSessionCertResponse?
    ) {
        self.state = state
        self.result = result
        self.signature = signature
        self.cert = cert
    }
}

public struct SmartIdSessionSignatureResponse: Sendable, Decodable, CustomStringConvertible {
    public let value: Data
    public let algorithm: String

    public var description: String {
        return """
        SmartIdSessionSignatureResponse(
            value: \(value.base64EncodedString()),
            algorithm: \(algorithm)
        )
        """
    }

    public init(value: Data, algorithm: String) {
        self.value = value
        self.algorithm = algorithm
    }
}

public enum SessionResponseState: String, Sendable, Decodable {
    case running = "RUNNING"
    case complete = "COMPLETE"
}

public struct SessionResult: Sendable, Decodable, CustomStringConvertible {
    public let endResult: SmartIdSessionStatusResponseCode
    public let documentNumber: String?

    public var description: String {
        return """
        SessionResult(
            endResult: \(endResult.rawValue),
            documentNumber: \(documentNumber ?? "-")
        )
        """
    }

    public init(
        endResult: SmartIdSessionStatusResponseCode,
        documentNumber: String?
    ) {
        self.endResult = endResult
        self.documentNumber = documentNumber
    }
}

public enum SessionCertificateLevel: String, Sendable, Decodable {
    case ADVANCED
    case QUALIFIED
    case QSCD
}

public struct SmartIdSessionCertResponse: Sendable, Decodable, CustomStringConvertible {
    public let value: Data?
    public let certificateLevel: SessionCertificateLevel?

    public var description: String {
        return """
        SmartIdSessionCertResponse(
            value: \(value?.base64EncodedString() ?? "-"),
            certificateLevel: \(certificateLevel.debugDescription)
        )
        """
    }

    public init(
        value: Data?,
        certificateLevel: SessionCertificateLevel?
    ) {
        self.value = value
        self.certificateLevel = certificateLevel
    }
}

public enum SmartIdSessionStatusResponseCode: String, Sendable, Decodable {
    // swiftlint:disable:next identifier_name
    case ok = "OK"
    case userRefused = "USER_REFUSED"
    case userRefusedDisplayTextAndPin = "USER_REFUSED_DISPLAYTEXTANDPIN"
    case userRefusedVcChoice = "USER_REFUSED_VC_CHOICE"
    case userRefusedConfirmationMessage = "USER_REFUSED_CONFIRMATIONMESSAGE"
    // swiftlint:disable:next identifier_name
    case userRefusedConfirmationMessageWithVcChoice = "USER_REFUSED_CONFIRMATIONMESSAGE_WITH_VC_CHOICE"
    case userRefusedCertChoice = "USER_REFUSED_CERT_CHOICE"
    case requiredInteractionNotSupportedByApp = "REQUIRED_INTERACTION_NOT_SUPPORTED_BY_APP"
    case timeout = "TIMEOUT"
    case documentUnusable = "DOCUMENT_UNUSABLE"
    case wrongVc = "WRONG_VC"
    case unknown = "UNKNOWN"

    public init(from decoder: any Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        self = SmartIdSessionStatusResponseCode(rawValue: rawValue) ?? .unknown
    }
}
