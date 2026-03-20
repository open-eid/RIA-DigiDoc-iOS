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
import Security
import CryptoKit

enum SignatureVerifierError: Error {
    case invalidPEM
    case invalidBase64
    case unsupportedKeySize(Int)
}

struct SignatureVerifier {

    static func verify(signature: String, publicKeyPEM: String, signedContent: String) -> Bool {
        do {
            let pubKeyDER = try parsePublicKeyDER(fromPEM: publicKeyPEM)
            let sigDER = try decodeBase64(signature)

            let messageData = Data(signedContent.utf8)

            return try verifyECDSASignature(
                signatureDER: sigDER,
                publicKeyDER: pubKeyDER,
                message: messageData
            )
        } catch {
            return false
        }
    }

    // MARK: - PEM / Base64 helpers

    private static func parsePublicKeyDER(fromPEM pem: String) throws -> Data {
        let possibleHeaders = [
            ("-----BEGIN PUBLIC KEY-----", "-----END PUBLIC KEY-----"),
            ("-----BEGIN EC PUBLIC KEY-----", "-----END EC PUBLIC KEY-----")
        ]

        guard let (begin, end) = possibleHeaders.first(
            where: { (begin, end) in
                pem.contains(begin) && pem.contains(end)
            }
        ) else {
            throw SignatureVerifierError.invalidPEM
        }

        let payload = pem
            .replacing(begin, with: "")
            .replacing(end, with: "")

        let cleaned = removeAllWhitespace(data: payload)
        return try decodeBase64(cleaned)
    }

    private static func decodeBase64(_ value: String) throws -> Data {
        let cleaned = removeAllWhitespace(data: value)
        guard let data = Data(base64Encoded: cleaned) else {
            throw SignatureVerifierError.invalidBase64
        }
        return data
    }

    private static func removeAllWhitespace(data: String) -> String {
        data.filter { !$0.isWhitespace && !$0.isNewline }
    }

    // MARK: - ECDSA verify (curve chosen by DER length heuristic)

    private static func verifyECDSASignature(signatureDER: Data, publicKeyDER: Data, message: Data) throws -> Bool {
        switch publicKeyDER.count {
        case 80...100:
            let key = try P256.Signing.PublicKey(derRepresentation: publicKeyDER)
            let sig = try P256.Signing.ECDSASignature(derRepresentation: signatureDER)
            return key.isValidSignature(sig, for: message)

        case 110...130:
            let key = try P384.Signing.PublicKey(derRepresentation: publicKeyDER)
            let sig = try P384.Signing.ECDSASignature(derRepresentation: signatureDER)
            return key.isValidSignature(sig, for: message)

        case 150...170:
            let key = try P521.Signing.PublicKey(derRepresentation: publicKeyDER)
            let sig = try P521.Signing.ECDSASignature(derRepresentation: signatureDER)
            return key.isValidSignature(sig, for: message)

        default:
            throw SignatureVerifierError.unsupportedKeySize(publicKeyDER.count)
        }
    }
}
