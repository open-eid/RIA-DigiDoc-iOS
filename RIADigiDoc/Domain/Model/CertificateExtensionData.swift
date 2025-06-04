import Foundation

public struct CertificateExtensionData: Sendable {
    let id: UUID = UUID()
    let name: String
    let oid: String
    let critical: Bool
    let values: String
}
