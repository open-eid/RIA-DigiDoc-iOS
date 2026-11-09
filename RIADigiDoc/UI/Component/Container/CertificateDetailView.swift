// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import X509
import SwiftASN1
import FactoryKit
import LibdigidocLibSwift
import UtilsLib

struct CertificateDetailView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var viewModel: CertificateDetailViewModel

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
        ).replacing(",", with: ", ")
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
        certificate: Data
    ) {
        _viewModel = State(wrappedValue: Container.shared.certificateDetailViewModel())
        self.certificate = certificate
    }

    private var subjectNameItems: [SignatureDataItem] {
        [
            SignatureDataItem(title: "Country or Region", value: subjectCountryName),
            SignatureDataItem(title: "Organization", value: subjectOrganizationName),
            SignatureDataItem(title: "Organizational Unit", value: subjectOrganizationalUnitName),
            SignatureDataItem(title: "Common Name", value: subjectCommonName),
            SignatureDataItem(title: "Surname", value: subjectSurname),
            SignatureDataItem(title: "Given Name", value: subjectGivenName),
            SignatureDataItem(title: "Serial number", value: subjectSerialNumber)
        ]
    }

    private var issuerNameItems: [SignatureDataItem] {
        [
            SignatureDataItem(title: "Country or Region", value: issuerCountryName),
            SignatureDataItem(title: "Organization", value: issuerOrganizationName),
            SignatureDataItem(title: "Common Name", value: issuerCommonName),
            SignatureDataItem(title: "Other name", value: issuerOtherName),
            SignatureDataItem(title: "Serial Number", value: issuerSerialNumber),
            SignatureDataItem(title: "Version", value: version),
            SignatureDataItem(title: "Signature Algorithm", value: signatureAlgorithm),
            SignatureDataItem(title: "Not Valid Before", value: notValidBefore),
            SignatureDataItem(title: "Not Valid After", value: notValidAfter)
        ]
    }

    private var publicKeyItems: [SignatureDataItem] {
        [
            SignatureDataItem(title: "Algorithm", value: publicKeyAlgorithm),
            SignatureDataItem(title: "Public Key", value: publicKey),
            SignatureDataItem(title: "Key Usage", value: keyUsage),
            SignatureDataItem(title: "Signature", value: signature)
        ]
    }

    private var fingerprintItems: [SignatureDataItem] {
        [
            SignatureDataItem(title: "SHA-256", value: sha256Fingerprint),
            SignatureDataItem(title: "SHA-1", value: sha1Fingerprint)
        ]
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Certificate details"),
            onLeftClick: { dismiss() },
            content: {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    detailSection(
                        "Subject Name",
                        topPadding: Dimensions.Padding.XSPadding,
                        items: subjectNameItems
                    )
                    detailSection(
                        "Issuer Name",
                        topPadding: Dimensions.Padding.MPadding,
                        items: issuerNameItems
                    )
                    detailSection(
                        "Public Key",
                        topPadding: Dimensions.Padding.MPadding,
                        items: publicKeyItems
                    )
                    extensionsSection
                    detailSection(
                        "Fingerprints",
                        topPadding: Dimensions.Padding.MPadding,
                        items: fingerprintItems
                    )
                }
                .padding(Dimensions.Padding.SPadding)
            }
        })
    }

    @ViewBuilder
    private func detailSection(
        _ title: String,
        topPadding: CGFloat,
        items: [SignatureDataItem]
    ) -> some View {
        let populatedItems = items.filter { !$0.value.isEmpty }
        if !populatedItems.isEmpty {
            sectionHeader(title, topPadding: topPadding)
            ForEach(populatedItems, id: \.title) { item in
                SignerDetailView(signatureDataItem: item)
            }
        }
    }

    @ViewBuilder
    private var extensionsSection: some View {
        if !extensions.isEmpty {
            sectionHeader("Extensions", topPadding: Dimensions.Padding.MPadding, heading: .h2)
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
    }

    private func sectionHeader(
        _ title: String,
        topPadding: CGFloat,
        heading: AccessibilityHeadingLevel = .h1
    ) -> some View {
        Text(verbatim: title)
            .foregroundStyle(theme.onSurface)
            .font(typography.titleLarge.bold())
            .padding(.vertical, Dimensions.Padding.XSPadding)
            .padding(.top, topPadding)
            .accessibilityHeading(heading)
            .accessibilityAddTraits([.isHeader])
    }
}

#Preview {
    CertificateDetailView(
        certificate: Data()
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
