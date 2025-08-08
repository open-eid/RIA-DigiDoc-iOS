import Foundation
import Testing
import Security
@testable import ConfigLib

final class SignatureVerifierTests {

    @Test
    func generateKeysAndSign_success() {
        guard let (publicKeyPEM, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "This is the content that was signed."
        guard let signature = TestRSAKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content")
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
        guard let (publicKeyPEM, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "Valid content to sign."
        _ = TestRSAKeyGenerator.sign(data: signedContent, privateKey: privateKey)
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
        guard let (publicKeyPEM, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let originalContent = "Valid content to sign."
        guard let signature = TestRSAKeyGenerator.sign(data: originalContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content")
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
        guard let (_, privateKey) = TestRSAKeyGenerator.generateKeyPair(),
              let (invalidPublicKeyPEM, _) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestRSAKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content")
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
        guard let (publicKeyPEM, _) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
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
        guard let (_, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestRSAKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content")
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
        guard let (publicKeyPEM, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestRSAKeyGenerator.sign(
            data: signedContent,
            privateKey: privateKey
        ) else {
            Issue.record("Failed to sign content")
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
        guard let (_, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "Valid content to sign."
        guard let signature = TestRSAKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content")
            return
        }

        let corruptedPEM = "-----BEGIN RSA PUBLIC KEY-----\nInvalidKeyData\n-----END RSA PUBLIC KEY-----"

        let result = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: corruptedPEM,
            signedContent: signedContent
        )

        #expect(!result)
    }
}
