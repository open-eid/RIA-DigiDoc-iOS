import Foundation
import SwiftASN1

/// @mockable
public protocol CertificateUtilProtocol: Sendable {
    func pemToDerData(fromPEM pem: Data) -> Data?
    func getSubjectAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String
    func getNotValidAfterWithExpiredLabel(cert: Data, expiredLabel: String) -> String
}
