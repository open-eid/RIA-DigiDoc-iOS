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

enum WebEidErrorCode: String, Codable, Sendable {
    case ERR_WEBEID_MOBILE_INVALID_REQUEST
    case ERR_WEBEID_MOBILE_UNKNOWN_ERROR
}

struct WebEidException: Error, LocalizedError, Sendable {
    let code: WebEidErrorCode
    let message: String
    let responseUri: String

    var errorDescription: String? {
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

enum WebEidAlgorithmUtilError: Error, LocalizedError {
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
        case .unsupportedHashFunction(let hf):
            return "Unsupported hash function: \(hf)"
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

