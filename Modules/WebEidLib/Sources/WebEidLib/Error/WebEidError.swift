// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
// swiftlint:disable identifier_name
public enum WebEidErrorCode: String, Codable, Sendable {
    case ERR_WEBEID_MOBILE_INVALID_REQUEST
    case ERR_WEBEID_MOBILE_UNKNOWN_ERROR
    case ERR_WEBEID_USER_CANCELLED
}
// swiftlint:enable identifier_name
public struct WebEidException: Error, LocalizedError, Sendable {
    public let code: WebEidErrorCode
    public let message: String
    public let responseUri: String

    public var errorDescription: String? {
        "\(code.rawValue): \(message) (responseUri: \(responseUri))"
    }
}

enum WebEidBuilderError: Error, LocalizedError, Sendable {
    case invalidCertificate
    case missingPublicKey
    case invalidJSON
    case invalidBase64

    var errorDescription: String? {
        switch self {
        case .invalidCertificate: return "Invalid X.509 certificate"
        case .missingPublicKey: return "Certificate public key is missing"
        case .invalidJSON: return "Failed to serialize auth token JSON"
        case .invalidBase64: return "Invalid Base64"
        }
    }
}

enum WebEidAlgorithmUtilError: Error, LocalizedError, Sendable, Equatable {
    case unsupportedKeyType
    case unsupportedECKeyLength(Int)
    case invalidBase64
    case invalidCertificate
    case unsupportedHashFunction(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedKeyType:
            return "Unsupported key type"
        case .unsupportedECKeyLength(let bits):
            return "Unsupported EC key length: \(bits)"
        case .invalidBase64:
            return "Invalid Base64"
        case .invalidCertificate:
            return "Invalid X.509 certificate"
        case .unsupportedHashFunction(let hashFunction):
            return "Unsupported hash function: \(hashFunction)"
        }
    }
}

enum WebEidResponseUtilError: Error, LocalizedError {
    case invalidResponseURI
    case couldNotBuildURL

    var errorDescription: String? {
        switch self {
        case .invalidResponseURI: return "Invalid response URI"
        case .couldNotBuildURL: return "Could not build response URL"
        }
    }
}
