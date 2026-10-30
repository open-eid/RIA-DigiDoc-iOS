// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import CryptoObjCWrapper
import UtilsLib

struct RecipientsView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @AccessibilityFocusState private var focusedField: AccessibilityField?

    @State private var showBottomSheet = false

    let recipient: Addressee
    let recipientIndex: Int

    let showMoreOptionsButton: Bool
    let accessibilityPrefixKey: String

    var onOpenRecipient: (() -> Void)?
    var onShowRecipientDetails: (() -> Void)?
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

    private var accessibilityPrefix: String {
        "\(languageSettings.localized(accessibilityPrefixKey)) \(recipientIndex + 1)"
    }

    private var moreOptionsLabel: String {
        languageSettings.localized("More options")
    }

    private var bottomSheetActions: [BottomSheetButton] {
        RecipientBottomSheetActions.actions(
            showRemoveRecipientButton: true,
            onDetailsButtonClick: { onShowRecipientDetails?() },
            onRemoveRecipientButtonClick: { onRemoveRecipient?() }
        )
    }

    init(
        recipient: Addressee,
        recipientIndex: Int,
        showMoreOptionsButton: Bool,
        accessibilityPrefixKey: String = "Recipient",
        onOpenRecipient: (() -> Void)? = nil,
        onShowRecipientDetails: (() -> Void)? = nil,
        onRemoveRecipient: (() -> Void)? = nil,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        recipientUtil: RecipientUtilProtocol = Container.shared.recipientUtil(),
    ) {
        self.recipient = recipient
        self.recipientIndex = recipientIndex
        self.showMoreOptionsButton = showMoreOptionsButton
        self.accessibilityPrefixKey = accessibilityPrefixKey
        self.onOpenRecipient = onOpenRecipient
        self.onShowRecipientDetails = onShowRecipientDetails
        self.onRemoveRecipient = onRemoveRecipient
        self.nameUtil = nameUtil
        self.recipientUtil = recipientUtil
    }

    private var recipientInfo: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            StyledNameText(name: nameText, allCaps: false)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .accessibilityLabel(
                    Text(verbatim: "\(accessibilityPrefix), \(nameText.lowercased())")
                )

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

    private var moreOptionsButton: some View {
        Button(action: accessibleAction(
            voiceOverEnabled: voiceOverEnabled,
            focusedField: $focusedField,
            action: { showBottomSheet = true }
        ), label: {
            Image("ic_m3_more_vert_48pt_wght400")
                .resizable()
                .scaledToFit()
                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                .foregroundStyle(theme.onSurfaceVariant)
                .accessibilityHidden(true)
        })
        .frame(minWidth: Dimensions.Icon.IconSizeXS, minHeight: Dimensions.Icon.IconSizeXS)
        .contentShape(Rectangle())
        .accessibilityLabel(Text(verbatim: "\(accessibilityPrefix), \(moreOptionsLabel)"))
        .accessibilityInputLabels([moreOptionsLabel])
        .bottomSheet(isPresented: $showBottomSheet, actions: bottomSheetActions)
        .accessibilityFocusRestore(
            focusedField: $focusedField,
            field: .recipient(.openRecipientOptionsButton),
            when: showBottomSheet
        )
    }

    var body: some View {
        HStack(spacing: Dimensions.Padding.MSPadding) {
            Image(iconRes)
                .resizable()
                .scaledToFit()
                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                .foregroundStyle(theme.onSurface)
                .accessibilityHidden(true)

            if showMoreOptionsButton {
                recipientInfo
            } else {
                Button(
                    action: { onOpenRecipient?() },
                    label: { recipientInfo }
                )
            }

            Spacer()

            if showMoreOptionsButton {
                moreOptionsButton
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
        showMoreOptionsButton: true,
        accessibilityPrefixKey: "Added recipient",
        onShowRecipientDetails: {},
        onRemoveRecipient: {}
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
