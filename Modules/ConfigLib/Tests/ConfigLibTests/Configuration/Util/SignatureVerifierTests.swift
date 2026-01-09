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
import Testing
import CryptoKit
@testable import ConfigLib

// MARK: - Tests

final class SignatureVerifierTests {

    @Test
    func generateKeysAndSign_success() {
        guard let (publicKeyPEM, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "This is the content that was signed."
        guard let signature = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content with EC key")
            return
        }

        let result = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: publicKeyPEM,
            signedContent: signedContent
        )

        #expect(result)
    }

    @Test
    func verify_returnFalseWithInvalidSignature() {
        guard let (publicKeyPEM, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "Valid content to sign."
        _ = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey)

        let invalidSignature = "InvalidBase64Signature=="

        let result = SignatureVerifier.verify(
            signature: invalidSignature,
            publicKeyPEM: publicKeyPEM,
            signedContent: signedContent
        )

        #expect(!result)
    }

    @Test
    func verify_returnFalseWithModifiedContent() {
        guard let (publicKeyPEM, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let originalContent = "Valid content to sign."
        guard let signature = TestECKeyGenerator.sign(data: originalContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content with EC key")
            return
        }

        let modifiedContent = "Tampered content."

        let result = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: publicKeyPEM,
            signedContent: modifiedContent
        )

        #expect(!result)
    }

    @Test
    func verify_returnFalseWithInvalidPublicKey() {
        // Sign with one keypair...
        guard let (_, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate signing EC key pair")
            return
        }
        // ...verify with a different public key (same curve) so PEM parsing succeeds, but signature check fails.
        guard let (invalidPublicKeyPEM, _) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate verification EC key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content with EC key")
            return
        }

        let result = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: invalidPublicKeyPEM,
            signedContent: signedContent
        )

        #expect(!result)
    }

    @Test
    func verify_returnFalseWithEmptySignature() {
        guard let (publicKeyPEM, _) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "Valid content to sign."
        let emptySignature = ""

        let result = SignatureVerifier.verify(
            signature: emptySignature,
            publicKeyPEM: publicKeyPEM,
            signedContent: signedContent
        )

        #expect(!result)
    }

    @Test
    func verify_returnFalseWithEmptyPublicKey() {
        guard let (_, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content with EC key")
            return
        }

        let emptyPublicKeyPEM = ""

        let result = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: emptyPublicKeyPEM,
            signedContent: signedContent
        )

        #expect(!result)
    }

    @Test
    func verify_returnFalseWithEmptySignedContent() {
        guard let (publicKeyPEM, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content with EC key")
            return
        }

        let emptySignedContent = ""

        let result = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: publicKeyPEM,
            signedContent: emptySignedContent
        )

        #expect(!result)
    }

    @Test
    func verify_returnFalseWithCorruptedPEMFormat() {
        guard let (_, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content with EC key")
            return
        }

        // Corrupt / unsupported PEM header (your verifier only accepts PUBLIC KEY / EC PUBLIC KEY)
        let corruptedPEM = """
        -----BEGIN PUBLIC KEY-----
        InvalidKeyData
        -----END PUBLIC KEY-----
        """

        let result = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: corruptedPEM,
            signedContent: signedContent
        )

        #expect(!result)
    }
}
