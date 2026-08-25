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
