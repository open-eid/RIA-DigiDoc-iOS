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
import OSLog
import Testing
import Security
@testable import ConfigLib

struct TestRSAKeyGenerator {

    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "TestRSAKeyGenerator")

    static func generateKeyPair() -> (publicKeyPEM: String, privateKey: SecKey)? {
        let attributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey) else {
            TestRSAKeyGenerator.logger.error("Key generation error: \(String(describing: error?.takeRetainedValue()))")
            return nil
        }

        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            TestRSAKeyGenerator.logger.error(
                "Public key export error: \(String(describing: error?.takeRetainedValue()))"
            )
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
            TestRSAKeyGenerator.logger.error("Signing error: \(String(describing: error?.takeRetainedValue()))")
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
