import Foundation
import Testing
import Security
@testable import ConfigLib

struct TestRSAKeyGenerator {

    static func generateKeyPair() -> (publicKeyPEM: String, privateKey: SecKey)? {
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Key generation error: \(String(describing: error?.takeRetainedValue()))")
            return nil
        }

        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("Public key export error: \(String(describing: error?.takeRetainedValue()))")
            return nil
        }

        let publicKeyPEM = exportToPEM(data: publicKeyData, keyType: "RSA PUBLIC KEY")
        return (publicKeyPEM, privateKey)
    }

    static func sign(data: String, privateKey: SecKey) -> String? {
        guard let messageData = data.data(using: .utf8) else {
            return nil
        }

        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA512
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, algorithm, messageData as CFData, &error) else {
            print("Signing error: \(String(describing: error?.takeRetainedValue()))")
            return nil
        }

        return (signature as Data).base64EncodedString()
    }

    private static func exportToPEM(data: Data, keyType: String) -> String {
        let base64String = data.base64EncodedString()
        let lines = stride(from: 0, to: base64String.count, by: 64).map {
            base64String
                .index(base64String.startIndex, offsetBy: $0)..<base64String
                .index(base64String.startIndex, offsetBy: min($0 + 64, base64String.count))
        }.map { base64String[$0] }

        let pemString = """
        -----BEGIN \(keyType)-----
        \(lines.joined(separator: "\n"))
        -----END \(keyType)-----
        """
        return pemString
    }
}
