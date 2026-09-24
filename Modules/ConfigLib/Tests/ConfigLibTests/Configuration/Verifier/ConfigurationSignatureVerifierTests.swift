// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing
import CryptoKit
@testable import ConfigLib

struct ConfigurationSignatureVerifierTests {
    var configurationSignatureVerifier: ConfigurationSignatureVerifier!

    init() async throws {
        configurationSignatureVerifier = ConfigurationSignatureVerifier()
    }

    // MARK: - Tests

    @Test
    func generateKeysAndSign_success() async throws {
        guard let (publicKeyPEM, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "This is the content that was signed."
        guard let signature = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey) else {
            Issue.record("Failed to sign content with EC key")
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
        guard let (publicKeyPEM, privateKey) = TestECKeyGenerator.generateKeyPair(curve: .p521) else {
            Issue.record("Failed to generate EC key pair")
            return
        }

        let signedContent = "Valid content to sign."
        _ = TestECKeyGenerator.sign(data: signedContent, privateKey: privateKey)

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
