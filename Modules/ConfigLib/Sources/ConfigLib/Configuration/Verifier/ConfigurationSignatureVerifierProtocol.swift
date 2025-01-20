import Foundation

public protocol ConfigurationSignatureVerifierProtocol: Sendable {
    func verifyConfigurationSignature(config: String, publicKey: String, signature: String) throws
}
