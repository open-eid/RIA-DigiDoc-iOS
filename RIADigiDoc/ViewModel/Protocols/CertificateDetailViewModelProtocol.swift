import Foundation
import SwiftASN1

/// @mockable
@MainActor
public protocol CertificateDetailViewModelProtocol: Sendable {
    func getSubjectAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String
    func getIssuerAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String
    func getSerialNumber(cert: Data) -> String
    func getVersion(cert: Data) -> String
    func getSignatureAlgorithm(cert: Data) -> String
    func getNotValidBefore(cert: Data) -> String
    func getNotValidAfter(cert: Data) -> String
    func getPublicKeyAlgorithm(cert: Data) -> String
    func getPublicKeyHexString(cert: Data) -> String
    func getKeyUsage(cert: Data) -> String
    func getSignature(cert: Data) -> String
    func getExtensions(cert: Data) -> [CertificateExtensionData]
    func getSHA256Fingerprint(cert: Data) -> String
    func getSHA1Fingerprint(cert: Data) -> String
}
