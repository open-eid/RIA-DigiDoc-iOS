import Foundation
import OSLog
import X509
import SwiftASN1
import CryptoKit
import Security
import LibdigidocLibSwift
import UtilsLib

@MainActor
class CertificateDetailViewModel: ObservableObject {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "CertificateDetailViewModel")

    private static let oidToExtensionName: [String: String] = [
        "2.5.29.14": "SubjectKeyIdentifier",
        "2.5.29.15": "KeyUsage",
        "2.5.29.17": "SubjectAltName",
        "2.5.29.18": "IssuerAltName",
        "2.5.29.19": "BasicConstraints",
        "2.5.29.30": "NameConstraints",
        "2.5.29.31": "CRLDistributionPoints",
        "2.5.29.32": "CertificatePolicies",
        "2.5.29.33": "PolicyConstraints",
        "2.5.29.35": "AuthorityKeyIdentifier",
        "2.5.29.37": "ExtendedKeyUsage",
        "1.3.6.1.5.5.7.1.1": "Authority Information Access",
        "1.3.6.1.5.5.7.1.3": "QCStatements"
    ]

    func getSubjectAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(describing: certificate.subject
                .flatMap { $0 }
                .first { $0.type == attribute }?.value ?? RelativeDistinguishedName.Attribute
                .Value(utf8String: ""))
        } catch {
            CertificateDetailViewModel.logger.error(
                "Unable to get issuer attribute \(attribute) from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    func getIssuerAttribute(cert: Data, attribute: ASN1ObjectIdentifier) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(describing: certificate.issuer
                .flatMap { $0 }
                .first { $0.type == attribute }?.value ?? RelativeDistinguishedName.Attribute
                .Value(utf8String: ""))
        } catch {
            CertificateDetailViewModel.logger.error(
                "Unable to get issuer attribute \(attribute) from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    func getSerialNumber(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            return String(describing: certificate.serialNumber)
        } catch {
            CertificateDetailViewModel.logger.error(
                "Unable to get serial number from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    func getVersion(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })
            return String(describing: certificate.version)
        } catch {
            CertificateDetailViewModel.logger.error(
                "Unable to get version from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    func getSignatureAlgorithm(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })
            return String(describing: certificate.signatureAlgorithm).description
        } catch {
            CertificateDetailViewModel.logger.error(
                "Unable to get signature algorithm from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    func getNotValidBefore(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })
            return String(describing: certificate.notValidBefore)
        } catch {
            CertificateDetailViewModel.logger.error(
                "Unable to get not valid before from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    func getNotValidAfter(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })
            return String(describing: certificate.notValidAfter)
        } catch {
            CertificateDetailViewModel.logger.error(
                "Unable to get not valid after from certificate: \(error.localizedDescription)"
            )
            return ""
        }
    }

    func getPublicKeyAlgorithm(cert: Data) -> String {
        guard let certificate = SecCertificateCreateWithData(nil, cert as CFData) else {
            return ""
        }

        guard let publicKey = SecCertificateCopyKey(certificate) else {
            return ""
        }

        let attributes = SecKeyCopyAttributes(publicKey) as? [String: Any]
        guard let algorithmID = attributes?[kSecAttrKeyType as String] as? String else {
            return ""
        }

        switch algorithmID {
        case String(kSecAttrKeyTypeRSA):
            return "RSA"
        case String(kSecAttrKeyTypeEC):
            return "EC"
        case String(kSecAttrKeyTypeECSECPrimeRandom):
            return "EC SEC"
        default:
            return algorithmID
        }
    }

    func getPublicKeyHexString(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            let publicKey = certificate.publicKey

            let publicKeyBytes = publicKey.subjectPublicKeyInfoBytes

            return publicKeyBytes.hexString
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }

    func getKeyUsage(cert: Data) -> String {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            let extensions = certificate.extensions

            let keyUsage = try extensions.keyUsage

            if let keyUsageDescription = keyUsage?.description {
                return String(describing: keyUsageDescription)
            }

            return ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    func getSignature(cert: Data) -> String {
        do {
            let node: ASN1Node = try DER.parse(Array(cert))

            if case .constructed(let tbsCertificateNodes) = node.content {
                if let signatureNode = tbsCertificateNodes.first(where: { $0.identifier.tagNumber == 3 }),
                   case .primitive(let signature) = signatureNode.content {
                    return signature.hexString
                }
            }

            return ""
        } catch {
            return ""
        }
    }

    func getExtensions(cert: Data) -> [CertificateExtensionData] {
        do {
            let certificate = try Certificate(derEncoded: cert.map { $0 })

            var extensions = [CertificateExtensionData]()

            for ext in certificate.extensions {
                let extensionName = extensionName(for: ext.oid)

                let values = ext.value.hexString

                extensions.append(
                    CertificateExtensionData(
                        name: extensionName,
                        oid: ext.oid.description,
                        critical: ext.critical,
                        values: values
                    )
                )
            }

            return extensions
        } catch {
            return []
        }
    }

    func getSHA256Fingerprint(cert: Data) -> String {
        let sha256Hash = SHA256.hash(data: cert)
        return sha256Hash.hexString()
    }

    func getSHA1Fingerprint(cert: Data) -> String {
        let sha1Hash = Insecure.SHA1.hash(data: cert)
        return sha1Hash.hexString()
    }

    private func extensionName(for oid: ASN1ObjectIdentifier) -> String {
        let oidString = oid.description
        return CertificateDetailViewModel.oidToExtensionName[oidString] ?? oidString
    }
}
