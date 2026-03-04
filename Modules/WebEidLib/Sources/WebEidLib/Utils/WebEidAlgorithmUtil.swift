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
import Security
import UtilsLib

struct WebEidAlgorithmUtil: Loggable {
    static let supportedHashFunctions: [String] = [
        "SHA-224",
        "SHA-256",
        "SHA-384",
        "SHA-512",
        "SHA3-224",
        "SHA3-256",
        "SHA3-384",
        "SHA3-512",
    ]

    /// returns an array of JSON-like dictionaries.
    static func buildSupportedSignatureAlgorithms(publicKey: SecKey) throws -> [[String: Any]] {
        guard try isEC(publicKey) else {
            throw WebEidAlgorithmUtilError.unsupportedKeyType
        }

        return supportedHashFunctions.map { hashFunction in
            [
                "cryptoAlgorithm": "ECC",
                "hashFunction": hashFunction,
                "paddingScheme": "NONE"
            ]
        }
    }

    /// Uses EC key size (bits) -> ES256/ES384/ES512 (P-521 -> ES512)
    static func getAlgorithm(publicKey: SecKey) throws -> String {
        let bits = try getECKeySizeBits(publicKey)

        switch bits {
        case 256: return "ES256"
        case 384: return "ES384"
        case 521: return "ES512"
        default:
            throw WebEidAlgorithmUtilError.unsupportedECKeyLength(bits)
        }
    }

    static func buildSignatureAlgorithm(
        publicKey: SecKey,
        hashFunction: String
    ) throws -> [String: Any] {

        guard supportedHashFunctions.contains(hashFunction) else {
            throw WebEidAlgorithmUtilError.unsupportedHashFunction(hashFunction)
        }

        if try isEC(publicKey) {
            return [
                "cryptoAlgorithm": "ECC",
                "hashFunction": hashFunction,
                "paddingScheme": "NONE"
            ]
        } else if try isRSA(publicKey) {
            return [
                "cryptoAlgorithm": "RSA",
                "hashFunction": hashFunction,
                "paddingScheme": "PKCS1.5"
            ]
        } else {
            throw WebEidAlgorithmUtilError.unsupportedKeyType
        }
    }

    /// returns SecCertificate created from Base64 DER.
    static func parseCertificate(signingCertBase64: String) throws -> SecCertificate {
        guard let certBytes = base64DecodeFlexible(signingCertBase64) else {
            throw WebEidAlgorithmUtilError.invalidBase64
        }
        guard let cert = certificate(from: certBytes) else {
            throw WebEidAlgorithmUtilError.invalidCertificate
        }
        return cert
    }
    
    // MARK: - Helpers

    static func certificate(from data: Data) -> SecCertificate? {
        return SecCertificateCreateWithData(nil, data as CFData)
    }
    
    static func base64DecodeFlexible(_ str: String) -> Data? {
        var padded = str
        let remainder = padded.count % 4
        if remainder != 0 {
            padded += String(repeating: "=", count: 4 - remainder)
        }
        return Data(base64Encoded: padded, options: [.ignoreUnknownCharacters])
    }
    
    private static func getKeyAttributes(_ key: SecKey) throws -> [CFString: Any] {
        guard let attrs = SecKeyCopyAttributes(key) as? [CFString: Any] else {
            throw WebEidAlgorithmUtilError.unsupportedKeyType
        }
        return attrs
    }

    private static func isEC(_ key: SecKey) throws -> Bool {
        let attrs = try getKeyAttributes(key)
        return (attrs[kSecAttrKeyType] as? String) == (kSecAttrKeyTypeECSECPrimeRandom as String)
    }

    private static func isRSA(_ key: SecKey) throws -> Bool {
        let attrs = try getKeyAttributes(key)
        return (attrs[kSecAttrKeyType] as? String) == (kSecAttrKeyTypeRSA as String)
    }

    /// exposes key size directly (kSecAttrKeySizeInBits).
    private static func getECKeySizeBits(_ key: SecKey) throws -> Int {
        guard try isEC(key) else {
            throw WebEidAlgorithmUtilError.unsupportedKeyType
        }
        let attrs = try getKeyAttributes(key)
        guard let bits = attrs[kSecAttrKeySizeInBits] as? Int else {
            throw WebEidAlgorithmUtilError.unsupportedKeyType
        }
        return bits
    }
}

/// serialize the returned JSON objects into Data/String:
protocol JSONSerializable {}

extension Array: JSONSerializable {}
extension Dictionary: JSONSerializable {}

extension JSONSerializable {
    func toJSONData(pretty: Bool = false) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: self,
            options: pretty ? [.prettyPrinted] : []
        )
    }
}
