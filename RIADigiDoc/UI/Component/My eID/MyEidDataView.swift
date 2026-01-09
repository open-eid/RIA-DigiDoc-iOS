/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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
import LibdigidocLibSwift
import CommonsLib
import IdCardLib

struct MyEidDataView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var selectedTab: MyEidViewTab = .myData

    @State private var isPin1Blocked: Bool = false
    @State private var isPin2Blocked: Bool = false
    @State private var isPukBlocked: Bool = false
    @State private var isPin2Activated: Bool = false

    @State private var pinChangeVariant: PinChangeVariant?

    private var myDataTitle: String {
        languageSettings.localized("My data")
    }

    private var pinsAndCertificatesTitle: String {
        languageSettings.localized("PINs and certificates")
    }

    private var pukBlockedUrl: String {
        languageSettings.localized("PUK blocked URL")
    }

    private var opacityForPin1BlockedState: Double {
        getOpacityForBlockedState(isBlocked: isPin1Blocked && isPukBlocked)
    }

    private var opacityForPin2BlockedState: Double {
        getOpacityForBlockedState(isBlocked: isPin2Blocked && isPukBlocked)
    }

    private var opacityForPukBlockedState: Double {
        getOpacityForBlockedState(isBlocked: isPukBlocked)
    }

    private var isThales: Bool { false }

    private var pukCodeTitle: String {
        if isThales {
            return languageSettings.localized("PUK code")
        }
        return languageSettings.localized("Change PIN", [CodeType.puk.name])
    }

    private var pukCodeInfo: AttributedString {
        if isThales {
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

    private var pin1Guidelines: String {
        """
        • \(languageSettings.localized("PIN1 guideline 1"))
        • \(languageSettings.localized("PIN1 guideline 2"))
        • \(languageSettings.localized("PIN1 guideline 3"))
        """
    }

    private var pin2Guidelines: String {
        """
        • \(languageSettings.localized("PIN2 guideline 1"))
        • \(languageSettings.localized("PIN2 guideline 2"))
        • \(languageSettings.localized("PIN2 guideline 3"))
        """
    }

    private var pukGuidelines: String {
        """
        • \(languageSettings.localized("PUK guideline 1"))
        • \(languageSettings.localized("PUK guideline 2"))
        """
    }

    var body: some View {
        ZStack {
            TopBarContainer(
                title: languageSettings.localized("Main home my eid title"),
                onLeftClick: { dismiss()
                },
                content: {
                    ScrollView {
                        VStack {
                            TabView(selectedTab: $selectedTab, titles: [
                                myDataTitle,
                                pinsAndCertificatesTitle
                            ]) {
                                if selectedTab == .myData {
                                    MyEidDetailView(
                                        myEidDataItem: MyEidDataItem(
                                            title: "First name",
                                            value: "Some name"
                                        )
                                    )
                                    MyEidDetailView(
                                        myEidDataItem: MyEidDataItem(
                                            title: "Valid to",
                                            value: "1 January 2999",
                                            status: .valid
                                        )
                                    )
                                } else if selectedTab == .pinsAndCertificates {
                                    VStack {
                                        MyEidCertificateCardView(
                                            title: languageSettings.localized("Authentication certificate"),
                                            subtitle: AttributedString(languageSettings
                                                .localized("Certificate is valid until", ["1 January 2099"])),
                                            forgotPinText: isPin1Blocked ?
                                            languageSettings.localized("Unblock PIN", [CodeType.pin1.name]) :
                                                languageSettings.localized("Forgot PIN", [CodeType.pin1.name]),
                                            changePinText: languageSettings
                                                .localized("Change PIN", [CodeType.pin1.name]),
                                            isPinBlocked: isPin1Blocked,
                                            isPukBlocked: isPukBlocked,
                                            onForgotPinClick: {
                                                pinChangeVariant = .pin1Unblock
                                            },
                                            onChangePinClick: {
                                                pinChangeVariant = .pin1Change
                                            }
                                        )
                                        .opacity(opacityForPin1BlockedState)

                                        if isPin1Blocked {
                                            Text(verbatim: languageSettings.localized(
                                                "PIN blocked", [CodeType.pin1.name])
                                            )
                                            .font(typography.bodySmall)
                                            .foregroundStyle(theme.error)
                                            .padding(.vertical, Dimensions.Padding.XSPadding)
                                        }
                                    }
                                    .padding(.vertical, Dimensions.Padding.SPadding)

                                    VStack {
                                        MyEidCertificateCardView(
                                            title: languageSettings.localized("Signing certificate"),
                                            subtitle: AttributedString(
                                                languageSettings.localized(
                                                    "Certificate is valid until",
                                                    ["1 January 2099"]
                                                )
                                            ),
                                            forgotPinText: isPin1Blocked ?
                                            languageSettings.localized("Unblock PIN", [CodeType.pin2.name]) :
                                                languageSettings.localized("Forgot PIN", [CodeType.pin2.name]),
                                            changePinText: languageSettings
                                                .localized("Change PIN", [CodeType.pin2.name]),
                                            isPinBlocked: isPin2Blocked,
                                            isPukBlocked: isPukBlocked,
                                            onForgotPinClick: {
                                                pinChangeVariant = .pin2Unblock
                                            },
                                            onChangePinClick: {
                                                pinChangeVariant = .pin2Change
                                            }
                                        )
                                        .opacity(opacityForPin2BlockedState)

                                        if isPin2Blocked {
                                            Text(verbatim: languageSettings.localized(
                                                "PIN blocked", [CodeType.pin2.name])
                                            )
                                            .font(typography.bodySmall)
                                            .foregroundStyle(theme.error)
                                            .padding(.vertical, Dimensions.Padding.XSPadding)
                                        }
                                    }
                                    .padding(.bottom, Dimensions.Padding.SPadding)

                                    VStack {
                                        MyEidCertificateCardView(
                                            title: pukCodeTitle,
                                            subtitle: pukCodeInfo,
                                            isPukBlocked: isPukBlocked
                                        )
                                        .opacity(opacityForPukBlockedState)
                                        .onTapGesture {
                                            pinChangeVariant = .pukChange
                                        }
                                        .accessibilityAddTraits([.isButton])

                                        if isPukBlocked {
                                            VStack(alignment: .leading) {
                                                Text(verbatim: languageSettings.localized("PUK blocked"))
                                                    .font(typography.bodySmall)
                                                    .foregroundStyle(theme.error)
                                                    .padding(.vertical, Dimensions.Padding.XSPadding)

                                                if let pukBlockedInfoUrl = URL(string: pukBlockedUrl) {
                                                    additionalInformationLink(url: pukBlockedInfoUrl)
                                                        .padding(.vertical, Dimensions.Padding.XSPadding)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom, Dimensions.Padding.SPadding)
                                }
                            }
                        }
                        .padding(.horizontal, Dimensions.Padding.SPadding)
                    }
                }
            )

            if let modal = pinChangeVariant {
                pinGuideline(
                    pinVariant: modal,
                    onConfirm: {
                        switch modal {
                        case .pin1Change:
                            pathManager.navigate(to: .myEidPinView(pinAction: .change, codeType: .pin1))

                        case .pin1Unblock:
                            pathManager.navigate(to: .myEidPinView(pinAction: .unblock, codeType: .pin1))

                        case .pin2Change:
                            pathManager.navigate(to: .myEidPinView(pinAction: .change, codeType: .pin2))

                        case .pin2Unblock:
                            pathManager.navigate(to: .myEidPinView(pinAction: .unblock, codeType: .pin2))

                        case .pukChange:
                            pathManager.navigate(to: .myEidPinView(pinAction: .change, codeType: .puk))
                        }

                        pinChangeVariant = nil
                    },
                    onCancel: {
                        pinChangeVariant = nil
                    }
                )
            }
        }
    }

    private func getOpacityForBlockedState(isBlocked: Bool) -> Double {
        !isBlocked ? 1 : 0.5
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

    @ViewBuilder
    private func pinGuideline(
        pinVariant: PinChangeVariant,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {

        let config = configuration(for: pinVariant)

        ConfirmModalView(
            title: languageSettings.localized("PIN guideline title", [config.codeType.name]),
            message: config.guidelines,
            confirmButtonTitle: config.confirmTitle,
            cancelButtonTitle: languageSettings.localized("Close"),
            onConfirm: onConfirm,
            onCancel: onCancel
        )
    }

    private func configuration(
        for modal: PinChangeVariant
    ) -> (codeType: CodeType, guidelines: String, confirmTitle: String) {

        switch modal {
        case .pin1Change:
            return (
                .pin1,
                pin1Guidelines,
                languageSettings.localized("Change PIN", [CodeType.pin1.name])
            )

        case .pin1Unblock:
            return (
                .pin1,
                pin1Guidelines,
                languageSettings.localized("Unblock PIN", [CodeType.pin1.name])
            )

        case .pin2Change:
            return (
                .pin2,
                pin2Guidelines,
                languageSettings.localized("Change PIN", [CodeType.pin2.name])
            )

        case .pin2Unblock:
            return (
                .pin2,
                pin2Guidelines,
                languageSettings.localized("Unblock PIN", [CodeType.pin2.name])
            )

        case .pukChange:
            return (
                .puk,
                pukGuidelines,
                languageSettings.localized("Change PIN", [CodeType.puk.name])
            )
        }
    }

}

#Preview {
    MyEidRootView()
}
