import Foundation
import Testing
@testable import ConfigLib

struct ConfigurationSignatureVerifierTests {
    var configurationSignatureVerifier: ConfigurationSignatureVerifier!

    init() async throws {
        configurationSignatureVerifier = ConfigurationSignatureVerifier()
    }

    @Test
    func generateKeysAndSign_success() async throws {
        guard let (publicKeyPEM, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "This is the content that was signed."
        guard let signature = TestRSAKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content")
            return
        }

        #expect(throws: Never.self) {
            try configurationSignatureVerifier.verifyConfigurationSignature(
                config: signedContent,
                publicKey: publicKeyPEM,
                signature: signature
            )
        }
    }

    @Test
    func verify_throwSignatureValidationFailedErroWithInvalidSignature() {
        guard let (publicKeyPEM, privateKey) = TestRSAKeyGenerator.generateKeyPair() else {
            Issue.record("Failed to generate key pair")
            return
        }

        let signedContent = "Valid content to sign."
        _ = TestRSAKeyGenerator.sign(data: signedContent, privateKey: privateKey)
        let invalidSignature = "InvalidBase64Signature=="

        #expect(throws: ConfigurationSignatureVerificationError.signatureValidationFailed) {
            try configurationSignatureVerifier.verifyConfigurationSignature(
                config: signedContent,
                publicKey: publicKeyPEM,
                signature: invalidSignature
            )
        }
    }
}
