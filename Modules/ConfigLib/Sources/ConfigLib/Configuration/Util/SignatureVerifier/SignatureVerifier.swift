// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
