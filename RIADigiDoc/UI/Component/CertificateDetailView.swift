import SwiftUI
import X509
import SwiftASN1
import FactoryKit
import LibdigidocLibSwift
import UtilsLib

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable type_body_length file_length
struct CertificateDetailView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings

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
        viewModel: CertificateDetailViewModel = Container.shared.certificateDetailViewModel(),
        certificate: Data
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.certificate = certificate
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Certificate details"),
            onLeftClick: { dismiss() },
            content: {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text(verbatim: "Subject Name")
                        .foregroundStyle(theme.onSurface)
                        .font(typography.titleLarge.bold())
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                        .padding(.top, Dimensions.Padding.XSPadding)
                        .accessibilityHeading(.h1)

                    if !subjectCountryName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Country or Region",
                                value: subjectCountryName
                            )
                        )
                    }

                    if !subjectOrganizationName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Organization",
                                value: subjectOrganizationName
                            )
                        )
                    }

                    if !subjectOrganizationalUnitName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Organizational Unit",
                                value: subjectOrganizationalUnitName
                            )
                        )
                    }

                    if !subjectCommonName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Common Name",
                                value: subjectCommonName
                            )
                        )
                    }

                    if !subjectSurname.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Surname",
                                value: subjectSurname
                            )
                        )
                    }

                    if !subjectGivenName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Given Name",
                                value: subjectGivenName
                            )
                        )
                    }

                    if !subjectSerialNumber.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Serial number",
                                value: subjectSerialNumber
                            )
                        )
                    }

                    Text(verbatim: "Issuer Name")
                        .foregroundStyle(theme.onSurface)
                        .font(typography.titleLarge.bold())
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                        .padding(.top, Dimensions.Padding.MPadding)
                        .accessibilityHeading(.h1)

                    if !issuerCountryName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Country or Region",
                                value: issuerCountryName
                            )
                        )
                    }

                    if !issuerOrganizationName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Organization",
                                value: issuerOrganizationName
                            )
                        )
                    }

                    if !issuerCommonName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Common Name",
                                value: issuerCommonName
                            )
                        )
                    }

                    if !issuerOtherName.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Other name",
                                value: issuerOtherName
                            )
                        )
                    }

                    if !issuerSerialNumber.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Serial Number",
                                value: issuerSerialNumber
                            )
                        )
                    }

                    if !version.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Version",
                                value: version
                            )
                        )
                    }

                    if !signatureAlgorithm.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Signature Algorithm",
                                value: signatureAlgorithm
                            )
                        )
                    }

                    if !notValidBefore.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Not Valid Before",
                                value: notValidBefore
                            )
                        )
                    }

                    if !notValidAfter.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Not Valid After",
                                value: notValidAfter
                            )
                        )
                    }

                    Text(verbatim: "Public Key")
                        .foregroundStyle(theme.onSurface)
                        .font(typography.titleLarge.bold())
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                        .padding(.top, Dimensions.Padding.MPadding)
                        .accessibilityHeading(.h1)

                    if !publicKeyAlgorithm.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Algorithm",
                                value: publicKeyAlgorithm
                            )
                        )
                    }

                    if !publicKey.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Public Key",
                                value: publicKey
                            )
                        )
                    }

                    if !keyUsage.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Key Usage",
                                value: keyUsage
                            )
                        )
                    }

                    if !signature.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "Signature",
                                value: signature
                            )
                        )
                    }


                    Text(verbatim: "Extensions")
                        .foregroundStyle(theme.onSurface)
                        .font(typography.titleLarge.bold())
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                        .padding(.top, Dimensions.Padding.MPadding)
                        .accessibilityHeading(.h2)

                    if !extensions.isEmpty {
                        ForEach(extensions, id: \.id) { extensionItem in
                            Group {
                                Text(verbatim: "Extension")
                                    .foregroundStyle(theme.onSurface)
                                    .font(typography.bodyLarge.bold())

                                Text(verbatim: "\(extensionItem.name) (\(extensionItem.oid))")

                                VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                                    Text(verbatim: "Critical: \(extensionItem.critical ? "Yes" : "No")")
                                    Text(verbatim: "ID: \(extensionItem.values)")
                                }
                                .padding(.leading, Dimensions.Padding.SPadding)
                            }
                            .padding(Dimensions.Padding.XSPadding)
                        }
                    }

                    Text(verbatim: "Fingerprints")
                        .foregroundStyle(theme.onSurface)
                        .font(typography.titleLarge.bold())
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                        .padding(.top, Dimensions.Padding.MPadding)
                        .accessibilityHeading(.h1)

                    if !sha256Fingerprint.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "SHA-256",
                                value: sha256Fingerprint
                            )
                        )
                    }

                    if !sha1Fingerprint.isEmpty {
                        SignerDetailView(
                            signatureDataItem: SignatureDataItem(
                                title: "SHA-1",
                                value: sha1Fingerprint
                            )
                        )
                    }
                }
                .padding(Dimensions.Padding.SPadding)
            }
        })
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
            roles: ["Role 1", "Role 2"],
            city: "Test City",
            state: "Test State",
            country: "Test Country",
            zipCode: "Test12345",
            format: "BES/time-stamp",
            messageImprint: Data(),
            diagnosticsInfo: ""
        ),
        containerMimetype: "application/vnd.etsi.asic-e+zip",
        dataFilesCount: 1
    )
    .environmentObject(
        Container.shared.languageSettings())
}
