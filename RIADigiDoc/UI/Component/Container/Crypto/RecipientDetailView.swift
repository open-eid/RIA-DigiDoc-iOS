/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import SwiftUI
import FactoryKit
import CryptoObjCWrapper
import UtilsLib

struct RecipientDetailView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.openURL) var openURL

    @State private var selectedTab: RecipientDetailViewTab = .recipientDetails

    @State private var viewModel: SignatureDetailViewModel

    private let recipient: Addressee

    private let nameUtil: NameUtilProtocol

    var recipientDetailsTitle: String {
        return languageSettings.localized("Recipient")
    }

    var nameText: String {
        return {
            if PersonalCodeValidator.isPersonalCodeValid(recipient.identifier) {
                return nameUtil.formatName(
                    surname: recipient.surname,
                    givenName: recipient.givenName,
                    identifier: recipient.identifier
                )
            } else {
                return nameUtil.formatCompanyName(
                    identifier: recipient.identifier,
                    serialNumber: recipient.serialNumber
                )
            }
        }()
    }

    var validToDate: String {
        guard let validToDate = recipient.validTo else { return "" }

        return DateUtil.getFormattedDateTime(
            date: validToDate,
            isUTC: false
        ).date
    }

    init(
        recipient: Addressee,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil()
    ) {
        _viewModel = State(wrappedValue: Container.shared.signatureDetailViewModel())
        self.recipient = recipient

        self.nameUtil = nameUtil
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Recipient details"),
            onLeftClick: { dismiss() },
            content: {
                ScrollView {
                    RecipientView(
                        recipientIndex: 0,
                        recipient: recipient,
                        showMoreOptionsButton: false,
                        showRemoveRecipientModal: .constant(false)
                    )

                    VStack(alignment: .leading) {
                        TabView(
                            selectedTab: $selectedTab,
                            titles: [recipientDetailsTitle],
                            content: {
                                VStack(alignment: .leading) {
                                    if selectedTab == .recipientDetails {
                                        let issuerName = viewModel.getIssuerName(cert: recipient.data)
                                        if !issuerName.isEmpty {
                                            SignerDetailView(
                                                signatureDataItem: SignatureDataItem(
                                                    title: languageSettings.localized("Recipient certificate issuer"),
                                                    value: viewModel.getIssuerName(cert: recipient.data)
                                                )
                                            )
                                        }

                                        if !nameText.isEmpty {
                                            NavigationLink(
                                                value: NavigationDestination
                                                    .certificateDetailView(certificate: recipient.data)
                                            ) {
                                                SignerDetailView(
                                                    signatureDataItem: SignatureDataItem(
                                                        title: languageSettings.localized("Recipient certificate"),
                                                        value: nameText,
                                                        extraIcon: "ic_m3_expand_content_48pt_wght400",
                                                    )
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        if !recipient.concatKDFAlgorithmURI.isEmpty {
                                            Button {
                                                if let url = URL(string: recipient.concatKDFAlgorithmURI) {
                                                    openURL(url)
                                                }
                                            } label: {
                                                SignerDetailView(
                                                    signatureDataItem: SignatureDataItem(
                                                        title: languageSettings.localized("ConcatKDF reference method"),
                                                        value: recipient.concatKDFAlgorithmURI,
                                                        extraIcon: "ic_m3_open_in_new_48pt_wght400",
                                                    )
                                                )
                                            }
                                            .buttonStyle(.plain)
                                            .accessibilityRemoveTraits([.isButton])
                                            .accessibilityAddTraits([.isLink])
                                        }
                                        if !validToDate.isEmpty {
                                            SignerDetailView(
                                                signatureDataItem: SignatureDataItem(
                                                    title: languageSettings.localized(
                                                        "Recipient certificate expiry date"
                                                    ),
                                                    value: validToDate
                                                )
                                            )
                                        }
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
    let recipient = Addressee(
        data: Data(),
        cnVal: "String",
        givenName: "Bob",
        surname: "Grey",
        serialNumber: "38208263812",
        certType: CertType.iDCardType,
        validTo: Date.distantFuture
    )

    RecipientDetailView(
        recipient: recipient
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
