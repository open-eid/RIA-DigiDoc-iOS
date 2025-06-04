import Foundation
import Security
import CommonCrypto

struct SignatureVerifier {

    static func verify(signature: String, publicKeyPEM: String, signedContent: String) -> Bool {
        guard let publicKey = parsePublicKey(fromPEM: publicKeyPEM) else {
            return false
        }
        return verifySignature(signature: signature, publicKey: publicKey, signedContent: signedContent)
    }

    private static func parsePublicKey(fromPEM pem: String) -> SecKey? {
        let der = removeAllWhitespace(data: pem
                                        .replacingOccurrences(of: "-----BEGIN RSA PUBLIC KEY-----", with: "")
                                        .replacingOccurrences(of: "-----END RSA PUBLIC KEY-----", with: "")
                                        .replacingOccurrences(of: "\n", with: ""))
        guard let pKey = Data(base64Encoded: der) else {
            return nil
        }

        let sizeInBits = pKey.count * 8
        let options: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
            kSecReturnPersistentRef: true
        ]

        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(pKey as CFData, options as CFDictionary, &error) else {
            return nil
        }

        return publicKey
    }

    private static func verifySignature(signature: String, publicKey: SecKey, signedContent: String) -> Bool {
        guard let messageData = signedContent.data(using: .utf8) else {
            return false
        }

        guard let signatureData = Data(base64Encoded: removeAllWhitespace(data: signature)) else {
            return false
        }

        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA512

        guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm) else {
            return false
        }

        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(publicKey, algorithm, messageData as CFData, signatureData as CFData, &error)

        return result
    }

    private static func removeAllWhitespace(data: String) -> String {
        return data.filter { !" \n\t\r".contains($0) }
    }
}
