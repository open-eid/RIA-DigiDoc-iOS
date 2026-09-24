// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import CryptoObjCWrapper
import CommonsLib
import UtilsLib

struct RecipientView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(NavigationPathManager.self) private var pathManager

    @AccessibilityFocusState private var focusedField: AccessibilityField?

    let recipientIndex: Int

    let recipient: Addressee
    let nameUtil: NameUtilProtocol
    let recipientUtil: RecipientUtilProtocol
    let showMoreOptionsButton: Bool
    var showRemoveRecipientButton: Bool
    @Binding var showRemoveRecipientModal: Bool
    var onSelect: (() -> Void)?

    @State private var showDetail = false
    @State private var showBottomSheetFromButton = false
    @State private var isVoiceOverObserverAdded = false
    @State private var isVoiceOverRunning = UIAccessibility.isVoiceOverRunning

    private var bottomSheetActions: [BottomSheetButton] {
        RecipientBottomSheetActions.actions(
            showRemoveRecipientButton: showRemoveRecipientButton,
            onDetailsButtonClick: {
                pathManager
                    .navigate(
                        to: .recipientDetailView(
                            recipient: recipient
                        )
                    )

            },
            onRemoveRecipientButtonClick: {
                onSelect?()
                showRemoveRecipientModal = true
            }
        )
    }

    var iconRes: String {
        if (recipient.surname?.isEmpty ?? true) && (recipient.givenName?.isEmpty ?? true) {
            return "ic_m3_domain_48pt_wght400"
        } else {
            return "ic_m3_encrypted_48pt_wght400"
        }
    }

    private var isPasswordRecipient: Bool {
        recipient.certType == .passwordType
    }

    var nameText: String {
        if isPasswordRecipient { return recipient.identifier }
        if PersonalCodeValidator.isPersonalCodeValid(recipient.identifier) {
            return nameUtil.formatName(
                surname: recipient.surname,
                givenName: recipient.givenName,
                identifier: recipient.identifier
            )
        }
        return nameUtil.formatCompanyName(
            identifier: recipient.identifier,
            serialNumber: recipient.serialNumber
        )
    }

    var validToDate: String {
        guard let validToDate = recipient.validTo else { return "" }

        return DateUtil.getFormattedDateTime(
            date: validToDate,
            isUTC: false
        ).date
    }

    init(
        recipientIndex: Int,
        recipient: Addressee,
        isTimestamp _: Bool = false,
        nameUtil: NameUtilProtocol = Container.shared.nameUtil(),
        recipientUtil: RecipientUtilProtocol = Container.shared.recipientUtil(),
        showMoreOptionsButton: Bool = true,
        showRemoveRecipientButton: Bool = true,
        showRemoveRecipientModal: Binding<Bool>,
        onSelect: (() -> Void)? = nil
    ) {
        self.recipientIndex = recipientIndex
        self.recipient = recipient
        self.nameUtil = nameUtil
        self.recipientUtil = recipientUtil
        self.showMoreOptionsButton = showMoreOptionsButton
        self.showRemoveRecipientButton = showRemoveRecipientButton
        self._showRemoveRecipientModal = showRemoveRecipientModal
        self.onSelect = onSelect
    }

    var body: some View {
        VStack {
            HStack {
                Image(iconRes)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurface)
                    .padding(.trailing, Dimensions.Padding.SPadding)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                    StyledNameText(name: nameText, allCaps: false)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .accessibilityLabel(
                            recipientIndex != 0 ?
                            Text(
                                verbatim: "\(languageSettings.localized("Recipient")) " +
                                "\(recipientIndex), \(nameText.lowercased())"
                            ) :
                            Text(verbatim: nameText.lowercased())
                        )

                    let certType = recipientUtil.getRecipientCertTypeText(certType: recipient.certType)
                    let validPart = (validToDate.isEmpty || isPasswordRecipient)
                        ? ""
                        : " " + languageSettings.localized("Valid to", [validToDate])

                    Text(verbatim: languageSettings.localized(certType) + validPart)
                        .font(typography.bodyMedium)
                        .foregroundStyle(theme.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .accessibilityElement(children: .combine)

                Spacer()

                if showMoreOptionsButton {
                    Button(action: accessibleAction(
                        voiceOverEnabled: voiceOverEnabled,
                        focusedField: $focusedField,
                        action: {
                            showBottomSheetFromButton = true
                        }
                    ), label: {
                        Image("ic_m3_more_vert_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onSurfaceVariant)
                            .accessibilityLabel(
                                Text(verbatim:
                                        "\(languageSettings.localized("Recipient")) " +
                                     "\(recipientIndex), \(languageSettings.localized("More options"))"
                                    )
                            )
                    })
                    .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
                    .accessibilityFocusRestore(
                        focusedField: $focusedField,
                        field: .signature(.openSignatureOptionsButton),
                        when: showBottomSheetFromButton
                    )
                }
            }
            .padding(Dimensions.Padding.MSPadding)
        }
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets())
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

    RecipientView(
        recipientIndex: 1,
        recipient: recipient,
        nameUtil: Container.shared.nameUtil(),
        recipientUtil: Container.shared.recipientUtil(),
        showRemoveRecipientModal: .constant(false)
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
