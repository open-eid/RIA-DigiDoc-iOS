import SwiftUI
import X509
import SwiftASN1
import LibdigidocLibSwift
import UtilsLib

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable type_body_length file_length
struct CertificateDetailView: View {
    @EnvironmentObject var languageSettings: LanguageSettings

    @StateObject private var viewModel: CertificateDetailViewModel

    private let certificate: Data

    private var subjectCountryName: String {
        return viewModel.getSubjectAttribute(
            cert: certificate,
            attribute: .RDNAttributeType.countryName)
    }

    private var subjectOrganizationName: String {
        return viewModel.getSubjectAttribute(
            cert: certificate,
            attribute: .RDNAttributeType.organizationName)
    }

    private var subjectOrganizationalUnitName: String {
        return viewModel.getSubjectAttribute(
            cert: certificate,
            attribute: .RDNAttributeType.organizationalUnitName)
    }

    private var subjectCommonName: String {
        return TextUtil.removeSlashes(
            viewModel.getSubjectAttribute(
                cert: certificate,
                attribute: .RDNAttributeType.commonName)
        ).replacingOccurrences(of: ",", with: ", ")
    }

    private var subjectSurname: String {
        return viewModel.getSubjectAttribute(
            cert: certificate,
            attribute: .NameAttributes.surname)
    }

    private var subjectGivenName: String {
        return viewModel.getSubjectAttribute(
            cert: certificate,
            attribute: .NameAttributes.givenName)
    }

    private var subjectSerialNumber: String {
        return viewModel.getSubjectAttribute(
            cert: certificate,
            attribute: .NameAttributes.serialNumber)
    }

    private var issuerCountryName: String {
        return viewModel.getIssuerAttribute(
            cert: certificate,
            attribute: .RDNAttributeType.countryName)
    }

    private var issuerOrganizationName: String {
        return viewModel.getIssuerAttribute(
            cert: certificate,
            attribute: .RDNAttributeType.organizationName)
    }

    private var issuerCommonName: String {
        return viewModel.getIssuerAttribute(
            cert: certificate,
            attribute: .RDNAttributeType.commonName)
    }

    private var issuerOtherName: String {
        return viewModel.getIssuerAttribute(
            cert: certificate,
            attribute: ASN1ObjectIdentifier(stringLiteral: "2.5.4.97"))
    }

    private var issuerSerialNumber: String {
        return TextUtil.formatSerialNumber(
            viewModel.getSerialNumber(cert: certificate)
        )
    }

    private var version: String {
        return viewModel.getVersion(cert: certificate)
    }

    private var signatureAlgorithm: String {
        return viewModel.getSignatureAlgorithm(cert: certificate)
    }

    private var notValidBefore: String {
        return viewModel.getNotValidBefore(cert: certificate)
    }

    private var notValidAfter: String {
        return viewModel.getNotValidAfter(cert: certificate)
    }

    private var publicKeyAlgorithm: String {
        return viewModel.getPublicKeyAlgorithm(cert: certificate)
    }

    private var publicKey: String {
        return viewModel.getPublicKeyHexString(cert: certificate)
    }

    private var signature: String {
        return viewModel.getSignature(cert: certificate)
    }

    private var keyUsage: String {
        return viewModel.getKeyUsage(cert: certificate)
    }

    private var extensions: [CertificateExtensionData] {
        return viewModel.getExtensions(cert: certificate)
    }

    private var sha256Fingerprint: String {
        return viewModel.getSHA256Fingerprint(cert: certificate)
    }

    private var sha1Fingerprint: String {
        return viewModel.getSHA1Fingerprint(cert: certificate)
    }

    init(
        viewModel: CertificateDetailViewModel = AppAssembler.shared.resolve(CertificateDetailViewModel.self),
        certificate: Data
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.certificate = certificate
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text(verbatim: "Subject Name")
                    .font(.headline)
                    .accessibilityHeading(.h1)

                if !subjectCountryName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Country or Region")
                                .font(.subheadline)
                            Text(verbatim: subjectCountryName)
                        }
                    }
                }

                if !subjectOrganizationName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Organization")
                                .font(.subheadline)
                            Text(verbatim: subjectOrganizationName)
                        }
                    }
                }

                if !subjectOrganizationalUnitName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Organizational Unit")
                                .font(.subheadline)
                            Text(verbatim: subjectOrganizationalUnitName)
                        }
                    }
                }

                if !subjectCommonName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Common Name")
                                .font(.subheadline)
                            Text(verbatim: subjectCommonName)
                        }
                    }
                }

                if !subjectSurname.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Surname")
                                .font(.subheadline)
                            Text(verbatim: subjectSurname)
                        }
                    }
                }

                if !subjectGivenName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Given Name")
                                .font(.subheadline)
                            Text(verbatim: subjectGivenName)
                        }
                    }
                }

                if !subjectSerialNumber.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Serial number")
                                .font(.subheadline)
                            Text(verbatim: subjectSerialNumber)
                        }
                    }
                }

                Text(verbatim: "Issuer Name")
                    .font(.headline)
                    .accessibilityHeading(.h1)

                if !issuerCountryName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Country or Region")
                                .font(.subheadline)
                            Text(verbatim: issuerCountryName)
                        }
                    }
                }

                if !issuerOrganizationName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Organization")
                                .font(.subheadline)
                            Text(verbatim: issuerOrganizationName)
                        }
                    }
                }

                if !issuerCommonName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Common Name")
                                .font(.subheadline)
                            Text(verbatim: issuerCommonName)
                        }
                    }
                }

                if !issuerOtherName.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Other name")
                                .font(.subheadline)
                            Text(verbatim: issuerOtherName)
                        }
                    }
                }

                if !issuerSerialNumber.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Serial Number")
                                .font(.subheadline)
                            Text(verbatim: issuerSerialNumber)
                        }
                    }
                }

                if !version.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Version")
                                .font(.subheadline)
                            Text(verbatim: version)
                        }
                    }
                }

                if !signatureAlgorithm.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Signature Algorithm")
                                .font(.subheadline)
                            Text(verbatim: signatureAlgorithm)
                        }
                    }
                }

                if !notValidBefore.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Not Valid Before")
                                .font(.subheadline)
                            Text(verbatim: notValidBefore)
                        }
                    }
                }

                if !notValidAfter.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Not Valid After")
                                .font(.subheadline)
                            Text(verbatim: notValidAfter)
                        }
                    }
                }

                Text(verbatim: "Public Key")
                    .font(.headline)
                    .accessibilityHeading(.h1)

                if !publicKeyAlgorithm.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Algorithm")
                                .font(.subheadline)
                            Text(verbatim: publicKeyAlgorithm)
                        }
                    }
                }

                if !publicKey.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Public Key")
                                .font(.subheadline)
                            Text(verbatim: publicKey)
                        }
                    }
                }

                if !keyUsage.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Key Usage")
                                .font(.subheadline)
                            Text(verbatim: keyUsage)
                        }
                    }
                }

                if !signature.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "Signature")
                                .font(.subheadline)
                            Text(verbatim: signature)
                        }
                    }
                }

                Group {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(verbatim: "Extensions")
                            .font(.subheadline)
                    }
                }

                if !extensions.isEmpty {
                    ForEach(extensions, id: \.id) { extensionItem in
                        Group {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(verbatim: "Extension")

                                Text(verbatim: "\(extensionItem.name) (\(extensionItem.oid))")

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(verbatim: "Critical: \(extensionItem.critical ? "Yes" : "No")")
                                        .padding(.leading, 16)
                                    Text(verbatim: "ID: \(extensionItem.values)")
                                        .padding(.leading, 16)
                                }
                            }
                        }
                        .padding()
                    }
                }

                Text(verbatim: "Fingerprints")
                    .font(.headline)
                    .accessibilityHeading(.h1)

                if !sha256Fingerprint.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "SHA-256")
                                .font(.subheadline)
                            Text(verbatim: sha256Fingerprint)
                        }
                    }
                }

                if !sha1Fingerprint.isEmpty {
                    Group {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verbatim: "SHA-1")
                                .font(.subheadline)
                            Text(verbatim: sha1Fingerprint)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(Text(languageSettings.localized("Certificate details")))
    }
}

#Preview {
    SignatureDetailView(
        signature: SignatureWrapper(
            signingCert: Data(),
            timestampCert: Data(),
            ocspCert: Data(),
            signatureId: "S1",
            claimedSigningTime: "1970-01-01T00:00:00Z",
            signatureMethod: "signature-method",
            ocspProducedAt: "1970-01-01T00:00:00Z",
            timeStampTime: "1970-01-01T00:00:00Z",
            signedBy: "Test User",
            trustedSigningTime: "1970-01-01T00:00:00Z",
            format: "BES/time-stamp",
            messageImprint: Data(),
            diagnosticsInfo: ""
        ),
        containerMimetype: "application/vnd.etsi.asic-e+zip",
        dataFilesCount: 1
    )
}
