// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct ConfigurationSignatureVerifier: ConfigurationSignatureVerifierProtocol {

    public init() {}

    public func verifyConfigurationSignature(config: String, publicKey: String, signature: String) throws {
        let signatureValid = SignatureVerifier.verify(
            signature: signature,
            publicKeyPEM: publicKey,
            signedContent: config
        )

        if !signatureValid {
            throw ConfigurationSignatureVerificationError.signatureValidationFailed
        }
    }
}
