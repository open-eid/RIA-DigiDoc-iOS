import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import UtilsLib

struct SignatureDetailView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.openURL) var openURL

    @State private var selectedTab = 0

    @StateObject private var viewModel: SignatureDetailViewModel
    private var certificateDetailViewModel: CertificateDetailViewModel

    private let signature: SignatureWrapper
    private let containerMimetype: String
    private let dataFilesCount: Int

    private let nameUtil: NameUtilProtocol

    var signersDetailsTitle: String {
        return languageSettings.localized("Signers details title")
    }

    var signersRoleAndAddressTitle: String {
        return languageSettings.localized("Signers role and address title")
    }

    var warningText: String {
        let key: String

        switch signature.status {
        case .warning:
            if signature.diagnosticsInfo.contains("Signature digest weak") {
                key = "Signature detail weak reason"
            } else {
                key = "Signature detail warning reason"
            }
        case .nonQSCD:
            key = "Signature detail non-qscd reason"
        case .unknown:
            key = "Signature detail unknown reason"
        default:
            key = "Signature detail invalid reason"
        }

        return languageSettings.localized(key)
    }

    var timeStampTime: String {
        let timestamp = DateUtil.getFormattedDateTime(
            dateTimeString: signature.timeStampTime,
            isUTC: false
        )
        return "\(timestamp.date) \(timestamp.time)"
    }

    var utcTimeStampTime: String {
        let utcTimestamp = DateUtil.getFormattedDateTime(
            dateTimeString: signature.timeStampTime,
            isUTC: true
        )
        return "\(utcTimestamp.date) \(utcTimestamp.time)"
    }

    var ocspTime: String {
        let ocspTime = DateUtil.getFormattedDateTime(
            dateTimeString: signature.ocspProducedAt,
            isUTC: false
        )
        return "\(ocspTime.date) \(ocspTime.time)"
    }

    var utcOcspTime: String {
        let utcOcspTime = DateUtil.getFormattedDateTime(
            dateTimeString: signature.ocspProducedAt,
            isUTC: true
        )
        return "\(utcOcspTime.date) \(utcOcspTime.time)"
    }

    var signersMobileTime: String {
        let mobileTime = DateUtil.getFormattedDateTime(
            dateTimeString: signature.claimedSigningTime,
            isUTC: true
        )
        return "\(mobileTime.date) \(mobileTime.time)"
    }

    init(
        viewModel: SignatureDetailViewModel = Container.shared.signatureDetailViewModel(),
        certificateDetailViewModel: CertificateDetailViewModel = Container.shared.certificateDetailViewModel(),
        signature: SignatureWrapper,
        containerMimetype: String,
        dataFilesCount: Int,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.certificateDetailViewModel = certificateDetailViewModel
        self.signature = signature
        self.containerMimetype = containerMimetype
        self.dataFilesCount = dataFilesCount

        self.nameUtil = nameUtil
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Signature details"),
            onLeftClick: { dismiss()
            },
            content: {
                ScrollView {
                    SignatureView(
                        containerMimetype: containerMimetype,
                        dataFilesCount: dataFilesCount,
                        signature: signature,
                        showSignedDate: false,
                        showMoreOptionsButton: false,
                        showRole: false
                    )

                    if let attributed = warningText.getURLFromText() {
                        Text(attributed)
                            .foregroundStyle(theme.onSurface)
                            .font(typography.bodyLarge)
                            .padding(.vertical, Dimensions.Padding.XSPadding)
                    } else {
                        Text(verbatim: warningText)
                            .foregroundStyle(theme.onSurface)
                            .font(typography.bodyLarge)
                            .padding(.vertical, Dimensions.Padding.XSPadding)
                    }

                    ExpandableButton(
                        title: languageSettings.localized("Technical information title"),
                        detailText: signature.diagnosticsInfo
                    )
                    .padding(.vertical, Dimensions.Padding.SPadding)

                    VStack(alignment: .leading) {
                        TabView(
                            selectedTab: $selectedTab,
                            titles: [signersRoleAndAddressTitle, signersDetailsTitle],
                            content: {
                                VStack(alignment: .leading) {
                                    if selectedTab == 0 {
                                        RoleDetailsView(signature: signature)
                                    } else {
                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Signer's certificate issuer"),
                                                value: viewModel.getIssuerName(cert: signature.signingCert)
                                            )
                                        )

                                        NavigationLink(
                                            destination: CertificateDetailView(
                                                certificate: signature.signingCert
                                            )
                                        ) {
                                            SignerDetailView(
                                                signatureDataItem: SignatureDataItem(
                                                    title: languageSettings.localized("Signer's Certificate"),
                                                    value: nameUtil.formatName(signature.signedBy),
                                                    extraIcon: "ic_m3_expand_content_48pt_wght400",
                                                )
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        Button {
                                            if let url = URL(string: signature.signatureMethod) {
                                                openURL(url)
                                            }
                                        } label: {
                                            SignerDetailView(
                                                signatureDataItem: SignatureDataItem(
                                                    title: languageSettings.localized("Signature method"),
                                                    value: signature.signatureMethod,
                                                    extraIcon: "ic_m3_open_in_new_48pt_wght400",
                                                )
                                            )
                                        }
                                        .buttonStyle(.plain)

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Container format"),
                                                value: containerMimetype
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Signature format"),
                                                value: signature.format
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Signed file count"),
                                                value: String(dataFilesCount)
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Signature timestamp"),
                                                value: timeStampTime
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Signature timestamp (UTC)"),
                                                value: utcTimeStampTime
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Hash value of signature"),
                                                value: signature.messageImprint.hexString
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("TS Certificate issuer"),
                                                value: viewModel.getIssuerName(cert: signature.timestampCert)
                                            )
                                        )

                                        NavigationLink(
                                            destination: CertificateDetailView(
                                                certificate: signature.timestampCert
                                            )
                                        ) {
                                            SignerDetailView(
                                                signatureDataItem: SignatureDataItem(
                                                    title: languageSettings.localized("TS Certificate"),
                                                    value: viewModel.getSubjectName(cert: signature.timestampCert),
                                                    extraIcon: "ic_m3_expand_content_48pt_wght400",
                                                )
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("OCSP Certificate issuer"),
                                                value: viewModel.getIssuerName(cert: signature.ocspCert)
                                            )
                                        )

                                        NavigationLink(
                                            destination: CertificateDetailView(
                                                certificate: signature.ocspCert
                                            )
                                        ) {
                                            SignerDetailView(
                                                signatureDataItem: SignatureDataItem(
                                                    title: languageSettings.localized("OCSP Certificate"),
                                                    value: viewModel.getSubjectName(cert: signature.ocspCert),
                                                    extraIcon: "ic_m3_expand_content_48pt_wght400",
                                                )
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("OCSP time"),
                                                value: ocspTime
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("OCSP time (UTC)"),
                                                value: utcOcspTime
                                            )
                                        )

                                        SignerDetailView(
                                            signatureDataItem: SignatureDataItem(
                                                title: languageSettings.localized("Signer's mobile time"),
                                                value: signersMobileTime
                                            )
                                        )
                                    }
                                }
                            })
                    }
                }
                .padding(Dimensions.Padding.SPadding)
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
            signedBy: "Test User, 12345678900",
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
        Container.shared.languageSettings()
    )
}
