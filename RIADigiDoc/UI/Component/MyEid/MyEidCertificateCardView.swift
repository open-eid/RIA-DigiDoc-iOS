// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct MyEidCertificateCardView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let title: String
    let subtitle: AttributedString
    let forgotPinText: String
    let changePinText: String
    let isPinBlocked: Bool
    let isPukBlocked: Bool
    let isCourierCard: Bool
    let showForgotPin: Bool
    let onForgotPinClick: (() -> Void)?
    let onChangePinClick: (() -> Void)?
    @Binding var lastFocused: AccessibilityField?

    let forgotPinAccessibilityField: AccessibilityField
    let changePinAccessibilityField: AccessibilityField

    init(
        title: String,
        subtitle: AttributedString,
        forgotPinText: String = "",
        changePinText: String = "",
        isPinBlocked: Bool = false,
        isPukBlocked: Bool = false,
        isCourierCard: Bool = false,
        showForgotPin: Bool = true,
        onForgotPinClick: (() -> Void)? = nil,
        onChangePinClick: (() -> Void)? = nil,
        forgotPinAccessibilityField: AccessibilityField,
        changePinAccessibilityField: AccessibilityField,
        lastFocused: Binding<AccessibilityField?>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.forgotPinText = forgotPinText
        self.changePinText = changePinText
        self.isPinBlocked = isPinBlocked
        self.isPukBlocked = isPukBlocked
        self.isCourierCard = isCourierCard
        self.showForgotPin = showForgotPin
        self.onForgotPinClick = onForgotPinClick
        self.onChangePinClick = onChangePinClick
        self.forgotPinAccessibilityField = forgotPinAccessibilityField
        self.changePinAccessibilityField = changePinAccessibilityField
        self._lastFocused = lastFocused
    }

    var body: some View {
        VStack(spacing: Dimensions.Padding.MPadding) {
            HStack(
                alignment: .top,
                spacing: Dimensions.Padding.SPadding
            ) {
                Image("ic_m3_check_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: Dimensions.Icon.IconSizeXXS,
                        height: Dimensions.Icon.IconSizeXXS
                    )
                    .foregroundStyle(theme.surface)
                    .padding(Dimensions.Padding.XSPadding)
                    .background(theme.primary)
                    .clipShape(.circle)
                    .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: Dimensions.Padding.XSPadding
                ) {
                    Text(verbatim: title)
                        .font(typography.titleMedium)
                        .foregroundColor(theme.onSurface)

                    Text(subtitle)
                        .font(typography.bodyMedium)
                        .foregroundColor(theme.onSurface)
                }
                .accessibilityElement(children: .combine)

                Spacer()
            }

            if showForgotPin && !forgotPinText.isEmpty {
                HStack(spacing: Dimensions.Padding.MSPadding) {
                    PrimaryOutlinedButton(
                        text: forgotPinText,
                        assetImageName: nil,
                        isButtonEnabled: !isPukBlocked && !isCourierCard,
                        action: onForgotPinClick ?? {},
                        focusedField: forgotPinAccessibilityField,
                        currentFocus: $lastFocused
                    )
                    .accessibilityLabel(forgotPinText.lowercased())

                    PrimaryButton(
                        text: changePinText,
                        isButtonEnabled: !isPinBlocked && !isCourierCard,
                        action: onChangePinClick ?? {},
                        focusedField: changePinAccessibilityField,
                        currentFocus: $lastFocused
                    )
                    .accessibilityLabel(changePinText.lowercased())
                }
            }
        }
        .padding(Dimensions.Padding.SPadding)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
                .fill(theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
                        .stroke(
                            theme.outlineVariant,
                            lineWidth: Dimensions.Height.XSBorder
                        )
                )
        )
    }
}

#Preview {
    VStack {
        MyEidCertificateCardView(
            title: "Authentication certificate",
            subtitle: "Certificate is valid until 1. January 2999",
            forgotPinText: "Forgot PIN1?",
            changePinText: "Change PIN1",
            onForgotPinClick: {},
            forgotPinAccessibilityField: .myEid(.unblockPin1Button),
            changePinAccessibilityField: .myEid(.changePin1Button),
            lastFocused: .constant(.myEid(.changePin1Button))
        )
    }
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
