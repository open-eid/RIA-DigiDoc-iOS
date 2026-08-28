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

struct RecipientsView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    let recipient: Addressee
    let recipientIndex: Int

    let showRemoveButton: Bool
    let accessibilityPrefixKey: String

    var onOpenRecipient: (() -> Void)?
    var onRemoveRecipient: (() -> Void)?

    let nameUtil: NameUtilProtocol
    let recipientUtil: RecipientUtilProtocol

    var iconRes: String {
        if (recipient.surname?.isEmpty ?? true) && (recipient.givenName?.isEmpty ?? true) {
            return "ic_m3_domain_48pt_wght400"
        } else {
            return "ic_m3_encrypted_48pt_wght400"
        }
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
        recipientIndex: Int,
        showRemoveButton: Bool,
        accessibilityPrefixKey: String = "Recipient",
        onOpenRecipient: (() -> Void)? = nil,
        onRemoveRecipient: (() -> Void)? = nil,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        recipientUtil: RecipientUtilProtocol = Container.shared.recipientUtil(),
    ) {
        self.recipient = recipient
        self.recipientIndex = recipientIndex
        self.showRemoveButton = showRemoveButton
        self.accessibilityPrefixKey = accessibilityPrefixKey
        self.onOpenRecipient = onOpenRecipient
        self.onRemoveRecipient = onRemoveRecipient
        self.nameUtil = nameUtil
        self.recipientUtil = recipientUtil
    }

    var body: some View {
        HStack(spacing: Dimensions.Padding.MSPadding) {
            Image(iconRes)
                .resizable()
                .scaledToFit()
                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                .foregroundStyle(theme.onSurface)
                .accessibilityHidden(true)

            Button(
                action: { onOpenRecipient?() },
                label: {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                        StyledNameText(name: nameText, allCaps: false)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .accessibilityLabel({
                                let prefix = languageSettings.localized(accessibilityPrefixKey)
                                let name = nameText.lowercased()
                                return Text(verbatim: "\(prefix) \(recipientIndex + 1), \(name)")
                            }())

                        let certType = recipientUtil.getRecipientCertTypeText(certType: recipient.certType)
                        Text(verbatim:
                                "\(languageSettings.localized(certType)) " +
                                "\(languageSettings.localized("Valid to", [validToDate]))")
                        .font(typography.bodyMedium)
                        .foregroundStyle(theme.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    }
                    .accessibilityElement(children: .combine)
                }
            )

            Spacer()

            if showRemoveButton {
                Button(
                    action: { onRemoveRecipient?() },
                    label: {
                        Image("ic_m3_delete_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onSurface)
                            .accessibilityLabel(
                                Text(verbatim: languageSettings.localized("Remove recipient"))
                            )
                    })
            }
        }
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
    RecipientsView(
        recipient: recipient,
        recipientIndex: 0,
        showRemoveButton: true,
        onOpenRecipient: {},
        onRemoveRecipient: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
