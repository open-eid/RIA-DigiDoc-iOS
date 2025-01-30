import Foundation

struct CertificateExtensionData {
    let id: UUID = UUID()
    let name: String
    let oid: String
    let critical: Bool
    let values: String
}
