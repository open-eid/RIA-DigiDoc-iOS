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
    let certificateStatus: MyEidDocumentStatus?
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
        certificateStatus: MyEidDocumentStatus? = nil,
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
        self.certificateStatus = certificateStatus
        self.showForgotPin = showForgotPin
        self.onForgotPinClick = onForgotPinClick
        self.onChangePinClick = onChangePinClick
        self.forgotPinAccessibilityField = forgotPinAccessibilityField
        self.changePinAccessibilityField = changePinAccessibilityField
        self._lastFocused = lastFocused
    }

    private var statusIconDiameter: CGFloat {
        Dimensions.Icon.IconSizeXXS + Dimensions.Padding.XSPadding * 2
    }

    private var isCertificateUsable: Bool {
        certificateStatus == nil || certificateStatus == .valid
    }

    private var showsErrorIcon: Bool {
        !isCertificateUsable || isPinBlocked
    }

    private var subtitleColor: Color {
        isCertificateUsable ? theme.onSurface : theme.error
    }

    @ViewBuilder
    private var statusIcon: some View {
        if showsErrorIcon {
            Image("ic_m3_error_48pt_wght400")
                .resizable()
                .scaledToFit()
                .frame(
                    width: statusIconDiameter,
                    height: statusIconDiameter
                )
                .foregroundStyle(theme.error)
                .accessibilityHidden(true)
        } else {
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
        }
    }

    var body: some View {
        VStack(spacing: Dimensions.Padding.MPadding) {
            HStack(
                alignment: .top,
                spacing: Dimensions.Padding.SPadding
            ) {
                statusIcon

                VStack(
                    alignment: .leading,
                    spacing: Dimensions.Padding.XSPadding
                ) {
                    Text(verbatim: title)
                        .font(typography.titleMedium)
                        .foregroundColor(theme.onSurface)

                    Text(subtitle)
                        .font(typography.bodyMedium)
                        .foregroundColor(subtitleColor)
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

        MyEidCertificateCardView(
            title: "Signing certificate",
            subtitle: "Certificate has expired",
            forgotPinText: "Forgot PIN2?",
            changePinText: "Change PIN2",
            certificateStatus: .expired,
            onForgotPinClick: {},
            forgotPinAccessibilityField: .myEid(.unblockPin2Button),
            changePinAccessibilityField: .myEid(.changePin2Button),
            lastFocused: .constant(.myEid(.changePin2Button))
        )

        MyEidCertificateCardView(
            title: "Authentication certificate",
            subtitle: "Certificate is valid until 1. January 2999",
            forgotPinText: "Unblock PIN1",
            changePinText: "Change PIN1",
            isPinBlocked: true,
            certificateStatus: .valid,
            onForgotPinClick: {},
            forgotPinAccessibilityField: .myEid(.unblockPin1Button),
            changePinAccessibilityField: .myEid(.changePin1Button),
            lastFocused: .constant(.myEid(.changePin1Button))
        )
    }
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
