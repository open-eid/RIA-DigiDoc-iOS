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
import Testing
import CryptoKit
@testable import ConfigLib

// MARK: - Test helper (EC keygen + signing)

enum TestECCurve {
    case p256
    case p384
    case p521
}

struct TestECKeyGenerator {

    /// Generates an EC keypair and returns:
    /// - publicKeyPEM: "BEGIN PUBLIC KEY" (SPKI)
    /// - privateKey: an opaque signer (stored as Any) to pass into sign()
    static func generateKeyPair(curve: TestECCurve = .p521) -> (publicKeyPEM: String, privateKey: Any)? {
        switch curve {
        case .p256:
            let key = P256.Signing.PrivateKey()
            return (publicKeyPEM(from: key.publicKey.derRepresentation), key)

        case .p384:
            let key = P384.Signing.PrivateKey()
            return (publicKeyPEM(from: key.publicKey.derRepresentation), key)

        case .p521:
            let key = P521.Signing.PrivateKey()
            return (publicKeyPEM(from: key.publicKey.derRepresentation), key)
        }
    }

    /// Signs UTF-8 string data and returns Base64 of DER ECDSA signature (ASN.1 r,s).
    static func sign(data: String, privateKey: Any) -> String? {
        let message = Data(data.utf8)

        do {
            if let key = privateKey as? P256.Signing.PrivateKey {
                let sig = try key.signature(for: message)
                return sig.derRepresentation.base64EncodedString()
            }
            if let key = privateKey as? P384.Signing.PrivateKey {
                let sig = try key.signature(for: message)
                return sig.derRepresentation.base64EncodedString()
            }
            if let key = privateKey as? P521.Signing.PrivateKey {
                let sig = try key.signature(for: message)
                return sig.derRepresentation.base64EncodedString()
            }
            return nil
        } catch {
            return nil
        }
    }

    private static func publicKeyPEM(from der: Data) -> String {
        let b64 = der.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        return """
        -----BEGIN PUBLIC KEY-----
        \(b64)
        -----END PUBLIC KEY-----
        """
    }
}
