// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import nfclib

struct MyEidPinsAndCertificatesView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var isPin1Blocked: Bool
    @Binding var isPin2Blocked: Bool
    @Binding var isPukBlocked: Bool
    @Binding var isPin2Activated: Bool
    @Binding var pinChangeVariant: PinChangeVariant?
    var authCertValidTo: String
    var signCertValidTo: String
    var authCertStatus: MyEidDocumentStatus
    var signCertStatus: MyEidDocumentStatus
    var isPUKChangeable: Bool
    var isCourierCard: Bool

    @AccessibilityFocusState private var accessibilityFocus: AccessibilityField?
    @State private var lastFocused: AccessibilityField?
    @AccessibilityFocusState private var isPukFocused: Bool

    private var pin2LockedMessage: String {
        languageSettings.localized(
            "PIN2 locked"
        )
    }

    private var pin2LockedUrl: String {
        languageSettings.localized(
            "PIN2 locked URL"
        )
    }

    private var pukBlockedMessage: String {
        languageSettings.localized(
            isPUKChangeable ? "PUK blocked" : "PUK blocked Thales"
        )
    }

    private var pukBlockedUrl: String {
        languageSettings.localized(
            isPUKChangeable ? "PUK blocked URL" : "PUK blocked Thales URL"
        )
    }

    private var pin1BlockedMessage: String {
        let pinBlockedText = languageSettings.localized(
            "PIN blocked",
            [CodeType.pin1.name]
        )

        if isPukBlocked {
            return pinBlockedText
        }

        return "\(pinBlockedText) \(languageSettings.localized("PIN blocked unblock message", []))"
    }

    private var pin2BlockedMessage: String {
        let pinBlockedText = languageSettings.localized(
            "PIN blocked",
            [CodeType.pin2.name]
        )

        if isPukBlocked {
            return pinBlockedText
        }

        return "\(pinBlockedText) \(languageSettings.localized("PIN blocked unblock message", []))"
    }

    init(
        isPin1Blocked: Binding<Bool>,
        isPin2Blocked: Binding<Bool>,
        isPukBlocked: Binding<Bool>,
        isPin2Activated: Binding<Bool>,
        pinChangeVariant: Binding<PinChangeVariant?> = .constant(nil),
        authCertValidTo: String,
        signCertValidTo: String,
        authCertStatus: MyEidDocumentStatus,
        signCertStatus: MyEidDocumentStatus,
        isPUKChangeable: Bool,
        isCourierCard: Bool = false
    ) {
        self._isPin1Blocked = isPin1Blocked
        self._isPin2Blocked = isPin2Blocked
        self._isPukBlocked = isPukBlocked
        self._isPin2Activated = isPin2Activated
        self._pinChangeVariant = pinChangeVariant
        self.authCertValidTo = authCertValidTo
        self.signCertValidTo = signCertValidTo
        self.authCertStatus = authCertStatus
        self.signCertStatus = signCertStatus
        self.isPUKChangeable = isPUKChangeable
        self.isCourierCard = isCourierCard
    }

    private func certificateSubtitle(status: MyEidDocumentStatus, validTo: String) -> AttributedString {
        switch status {
        case .valid:
            return AttributedString(languageSettings.localized("Certificate is valid until", [validTo]))
        case .expired:
            return AttributedString(languageSettings.localized("Certificate has expired"))
        case .unknown:
            return AttributedString(languageSettings.localized("My eid status unknown"))
        }
    }

    private func certificateUnusableMessage(status: MyEidDocumentStatus, codeType: CodeType) -> String? {
        guard status == .expired else { return nil }
        return languageSettings.localized("PIN cannot be used certificate expired", [codeType.name])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
            VStack(alignment: .leading) {
                MyEidCertificateCardView(
                    title: languageSettings.localized("Authentication certificate"),
                    subtitle: certificateSubtitle(status: authCertStatus, validTo: authCertValidTo),
                    forgotPinText: isPin1Blocked ?
                    languageSettings.localized("Unblock PIN", [CodeType.pin1.name]) :
                        languageSettings.localized("Forgot PIN", [CodeType.pin1.name]),
                    changePinText: languageSettings
                        .localized("Change PIN", [CodeType.pin1.name]),
                    isPinBlocked: isPin1Blocked,
                    isPukBlocked: isPukBlocked,
                    isCourierCard: isCourierCard,
                    certificateStatus: authCertStatus,
                    onForgotPinClick: {
                        lastFocused = .myEid(.unblockPin1Button)
                        pinChangeVariant = .pin1Unblock
                    },
                    onChangePinClick: {
                        lastFocused = .myEid(.changePin1Button)
                        pinChangeVariant = .pin1Change
                    },
                    forgotPinAccessibilityField: .myEid(.unblockPin1Button),
                    changePinAccessibilityField: .myEid(.changePin1Button),
                    lastFocused: $lastFocused
                )
                .opacity(opacityForPin1BlockedState)

                if let authCertUnusableMessage = certificateUnusableMessage(
                    status: authCertStatus,
                    codeType: .pin1
                ) {
                    Text(verbatim: authCertUnusableMessage)
                        .font(typography.bodySmall)
                        .foregroundStyle(theme.error)
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                }

                if isPin1Blocked {
                    Text(verbatim: pin1BlockedMessage)
                        .font(typography.bodySmall)
                        .foregroundStyle(theme.error)
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                }

                if isCourierCard {
                    courierCardWarning()
                }
            }
            .padding(.bottom, Dimensions.Padding.SPadding)

            VStack(alignment: .leading) {
                MyEidCertificateCardView(
                    title: languageSettings.localized("Signing certificate"),
                    subtitle: certificateSubtitle(status: signCertStatus, validTo: signCertValidTo),
                    forgotPinText: isPin2Blocked ?
                    languageSettings.localized("Unblock PIN", [CodeType.pin2.name]) :
                        languageSettings.localized("Forgot PIN", [CodeType.pin2.name]),
                    changePinText: languageSettings
                        .localized("Change PIN", [CodeType.pin2.name]),
                    isPinBlocked: isPin2Blocked,
                    isPukBlocked: isPukBlocked,
                    isCourierCard: isCourierCard,
                    certificateStatus: signCertStatus,
                    onForgotPinClick: {
                        lastFocused = .myEid(.unblockPin2Button)
                        pinChangeVariant = .pin2Unblock
                    },
                    onChangePinClick: {
                        lastFocused = .myEid(.changePin2Button)
                        pinChangeVariant = .pin2Change
                    },
                    forgotPinAccessibilityField: .myEid(.unblockPin2Button),
                    changePinAccessibilityField: .myEid(.changePin2Button),
                    lastFocused: $lastFocused
                )
                .opacity(opacityForPin2BlockedState)

                if let signCertUnusableMessage = certificateUnusableMessage(
                    status: signCertStatus,
                    codeType: .pin2
                ) {
                    Text(verbatim: signCertUnusableMessage)
                        .font(typography.bodySmall)
                        .foregroundStyle(theme.error)
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                }

                if isPin2Blocked {
                    Text(verbatim: pin2BlockedMessage)
                        .font(typography.bodySmall)
                        .foregroundStyle(theme.error)
                        .padding(.vertical, Dimensions.Padding.XSPadding)
                }

                if isCourierCard {
                    courierCardWarning()
                } else if !isPin2Activated && signCertStatus != .expired {
                    Text(verbatim: pin2LockedMessage)
                        .font(typography.bodySmall)
                        .foregroundStyle(theme.error)
                        .padding(.vertical, Dimensions.Padding.XSPadding)

                    if let pin2LockedInfoUrl = URL(string: pin2LockedUrl) {
                        additionalInformationLink(url: pin2LockedInfoUrl)
                            .padding(.vertical, Dimensions.Padding.XSPadding)
                    }
                }
            }
            .padding(.bottom, Dimensions.Padding.SPadding)

            VStack(alignment: .leading) {
                MyEidCertificateCardView(
                    title: pukCodeTitle,
                    subtitle: pukCodeInfo,
                    isPinBlocked: isPukBlocked,
                    isPukBlocked: isPukBlocked,
                    forgotPinAccessibilityField: .myEid(.changePukButton),
                    changePinAccessibilityField: .myEid(.changePukButton),
                    lastFocused: $lastFocused
                )
                .opacity(opacityForPukBlockedState)
                .onTapGesture {
                    if isPUKChangeable {
                        lastFocused = .myEid(.changePukButton)
                        pinChangeVariant = .pukChange
                    }
                }
                .accessibilityAddTraits([.isButton])
                .accessibilityFocused($isPukFocused)
                .task {
                    isPukFocused = lastFocused == .myEid(.changePukButton)
                }

                if isPukBlocked {
                    Text(verbatim: pukBlockedMessage)
                        .font(typography.bodySmall)
                        .foregroundStyle(theme.error)
                        .padding(.vertical, Dimensions.Padding.XSPadding)

                    if let pukBlockedInfoUrl = URL(string: pukBlockedUrl) {
                        additionalInformationLink(url: pukBlockedInfoUrl)
                            .padding(.vertical, Dimensions.Padding.XSPadding)
                    }
                }
            }
            .padding(.bottom, Dimensions.Padding.SPadding)
        }
    }

    private func getOpacityForBlockedState(isBlocked: Bool) -> Double {
        !isBlocked ? 1 : 0.5
    }

    private var opacityForPin1BlockedState: Double {
        getOpacityForBlockedState(isBlocked: (isPin1Blocked && isPukBlocked) || isCourierCard)
    }

    private var opacityForPin2BlockedState: Double {
        getOpacityForBlockedState(isBlocked: (isPin2Blocked && isPukBlocked) || isCourierCard)
    }

    private var opacityForPukBlockedState: Double {
        getOpacityForBlockedState(isBlocked: isPukBlocked)
    }

    private var pukCodeTitle: String {
        if !isPUKChangeable {
            return languageSettings.localized("PUK code")
        }
        return languageSettings.localized("Change PIN", [CodeType.puk.name])
    }

    private var pukCodeInfo: AttributedString {
        if !isPUKChangeable {
            let additionalInformation = languageSettings.localized("Additional information 2")

            var pukInfo = AttributedString(
            """
            \(languageSettings.localized("PUK code info"))

            \(languageSettings.localized("PUK code info 2"))

            \(additionalInformation)
            """
            )

            if let range = pukInfo.range(of: additionalInformation) {
                pukInfo[range].link = URL(string: pukBlockedUrl)
                pukInfo[range].foregroundColor = .link
                pukInfo[range].underlineStyle = .single
            }

            return pukInfo
        } else {
            return AttributedString(languageSettings.localized("PUK code info"))
        }
    }

    @ViewBuilder
    private func additionalInformationLink(url: URL) -> some View {
        Link(
            languageSettings.localized("Additional information"),
            destination: url
        )
        .underline()
        .font(typography.bodySmall)
        .foregroundStyle(.link)
    }

    private var courierWarningMessage: String {
        languageSettings.localized("ID card courier warning message")
    }

    private var courierActivateUrl: String {
        languageSettings.localized("ID card courier activate URL")
    }

    @ViewBuilder
    private func courierCardWarning() -> some View {
        Text(verbatim: courierWarningMessage)
            .font(typography.bodySmall)
            .foregroundStyle(theme.error)
            .padding(.vertical, Dimensions.Padding.XSPadding)

        if let url = URL(string: courierActivateUrl) {
            Link(
                languageSettings.localized("ID card courier activate button"),
                destination: url
            )
            .underline()
            .font(typography.bodySmall)
            .foregroundStyle(.link)
            .padding(.vertical, Dimensions.Padding.XSPadding)
        }
    }
}
