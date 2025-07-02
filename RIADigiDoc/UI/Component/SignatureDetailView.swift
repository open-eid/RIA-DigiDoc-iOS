import SwiftUI
import LibdigidocLibSwift
import UtilsLib

struct SignatureDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: SignatureDetailViewModel

    private let signature: SignatureWrapper
    private let containerMimetype: String
    private let dataFilesCount: Int

    private let nameUtil: NameUtilProtocol

    init(
        viewModel: SignatureDetailViewModel = AppAssembler.shared.resolve(SignatureDetailViewModel.self),
        signature: SignatureWrapper,
        containerMimetype: String,
        dataFilesCount: Int,
        nameUtil: NameUtilProtocol = UtilsLibAssembler.shared.resolve(NameUtilProtocol.self)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.signature = signature
        self.containerMimetype = containerMimetype
        self.dataFilesCount = dataFilesCount

        self.nameUtil = nameUtil
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Signature details"),
            onLeftClick: { dismiss() },
            content: {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Signer's certificate issuer:"))
                                    .font(.headline)
                                Text(verbatim: viewModel.getIssuerName(cert: signature.signingCert))
                            }
                        }

                        NavigationLink(destination: CertificateDetailView(certificate: signature.signingCert)) {
                            // TODO: Replace with Grid on iOS 16 (minimum version)?
                            Group {
                                VStack(alignment: .leading) {
                                    Text(languageSettings.localized("Signer's Certificate:"))
                                        .font(.headline)

                                    HStack(spacing: 5) {
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.gray)
                                            .accessibility(hidden: true)
                                    }

                                    Text(verbatim: nameUtil.formatName(signature.signedBy))
                                        .font(.body)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Signature method:"))
                                    .font(.headline)
                                Text(verbatim: signature.signatureMethod)
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Container format:"))
                                    .font(.headline)
                                Text(verbatim: containerMimetype)
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Signature format:"))
                                    .font(.headline)
                                Text(verbatim: signature.format)
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Signed file count:"))
                                    .font(.headline)
                                Text(verbatim: String(dataFilesCount))
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Signature timestamp:"))
                                    .font(.headline)
                                Text(verbatim: DateUtil.getFormattedDateTime(
                                    dateTimeString: signature.timeStampTime,
                                    isUTC: false).date
                                )
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Signature timestamp (UTC):"))
                                    .font(.headline)
                                Text(verbatim: DateUtil.getFormattedDateTime(
                                    dateTimeString: signature.timeStampTime,
                                    isUTC: true).date
                                )
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Hash value of signature:"))
                                    .font(.headline)
                                Text(verbatim: signature.messageImprint.hexString)
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("TS Certificate issuer:"))
                                    .font(.headline)
                                Text(verbatim: viewModel.getIssuerName(cert: signature.timestampCert))
                            }
                        }

                        NavigationLink(destination: CertificateDetailView(certificate: signature.timestampCert)) {
                            Group {
                                // TODO: Replace with Grid on iOS 16 (minimum version)?
                                VStack(alignment: .leading) {
                                    Text(languageSettings.localized("TS Certificate:"))
                                        .font(.headline)

                                    HStack(spacing: 5) {
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.gray)
                                            .accessibility(hidden: true)
                                    }

                                    Text(verbatim: viewModel.getSubjectName(cert: signature.timestampCert))
                                        .font(.body)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("OCSP Certificate issuer:"))
                                    .font(.headline)
                                Text(verbatim: viewModel.getIssuerName(cert: signature.ocspCert))
                            }
                        }

                        NavigationLink(destination: CertificateDetailView(certificate: signature.ocspCert)) {
                            Group {
                                // TODO: Replace with Grid on iOS 16 (minimum version)?
                                VStack(alignment: .leading) {
                                    Text(languageSettings.localized("OCSP Certificate:"))
                                        .font(.headline)

                                    HStack(spacing: 5) {
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.gray)
                                            .accessibility(hidden: true)
                                    }

                                    Text(verbatim: viewModel.getSubjectName(cert: signature.ocspCert))
                                        .font(.body)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("OCSP time:"))
                                    .font(.headline)
                                Text(verbatim: DateUtil.getFormattedDateTime(
                                    dateTimeString: signature.ocspProducedAt,
                                    isUTC: false).date
                                )
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("OCSP time (UTC):"))
                                    .font(.headline)
                                Text(verbatim: DateUtil.getFormattedDateTime(
                                    dateTimeString: signature.ocspProducedAt,
                                    isUTC: true).date
                                )
                            }
                        }

                        Group {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(languageSettings.localized("Signer's mobile time:"))
                                    .font(.headline)
                                Text(verbatim: DateUtil.getFormattedDateTime(
                                    dateTimeString: signature.claimedSigningTime,
                                    isUTC: true).date
                                )
                            }
                        }

                    }
                    .padding()
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
            format: "BES/time-stamp",
            messageImprint: Data(),
            diagnosticsInfo: ""
        ),
        containerMimetype: "application/vnd.etsi.asic-e+zip",
        dataFilesCount: 1
    )
}
