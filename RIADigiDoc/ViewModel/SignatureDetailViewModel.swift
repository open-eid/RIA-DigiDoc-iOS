import Foundation
import OSLog
import X509

@MainActor
class SignatureDetailViewModel: SignatureDetailViewModelProtocol, ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "SignatureDetailViewModel")

    func getIssuerName(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(
                describing: certificate.issuer
                    .flatMap { $0 }
                    .first { $0.type == .RDNAttributeType.commonName }?.value ??
                    RelativeDistinguishedName.Attribute.Value(utf8String: ""))
        } catch {
            SignatureDetailViewModel.logger
                .error("Unable to get issuer CommonName from certificate: \(error.localizedDescription)")
            return ""
        }
    }

    func getSubjectName(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(
                describing: certificate.subject
                    .flatMap { $0 }
                    .first { $0.type == .RDNAttributeType.commonName }?.value ??
                    RelativeDistinguishedName.Attribute.Value(utf8String: ""))
        } catch {
            SignatureDetailViewModel.logger
                .error("Unable to get subject CommonName from certificate: \(error.localizedDescription)")
            return ""
        }
    }
}
