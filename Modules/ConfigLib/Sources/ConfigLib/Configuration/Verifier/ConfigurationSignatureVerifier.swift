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
