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
import IdCardLib
import CommonsLib

struct MyEidPinChangeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var viewModel: MyEidPinChangeViewModel
    @State private var pinAction: MyEidPinCodeAction
    @State private var codeType: CodeType

    private var errorMessage: String {
        languageSettings.localized(viewModel.errorMessage ?? "", viewModel.errorMessageExtraArguments)
    }

    private var leftIcon: String {
        if viewModel.isFirstStep {
            return "ic_m3_close_48pt_wght400"
        } else {
            return "ic_m3_arrow_back_ios_48pt_wght400"
        }
    }

    private var leftIconAccessibility: String {
        viewModel.isFirstStep ? languageSettings.localized("Close") :
        languageSettings.localized("Back")
    }

    private var flowTitle: String {
        switch pinAction {
        case .change:
            return languageSettings.localized("Change PIN", [codeType.name])
        case .unblock:
            return languageSettings.localized("Unblock PIN", [codeType.name])
        }
    }

    private var stepTitle: String {
        switch viewModel.step {
        case .current:
            switch (pinAction, codeType) {
            case (.change, .pin1), (.change, .pin2), (.change, .puk):
                return languageSettings.localized("Enter current PIN code", [codeType.name])
            case (.unblock, .pin1), (.unblock, .pin2):
                return languageSettings.localized("Enter current PIN code", [CodeType.puk.name])
            default:
                return ""
            }
        case .new:
            return languageSettings.localized("Enter new PIN code", [codeType.name])
        case .confirm:
            return languageSettings.localized("Repeat new PIN code", [codeType.name])
        }
    }

    private var flowDescription: String {
        let pinLengthRequirement = languageSettings.localized(
            "PIN length requirement",
            [codeType.name, String(pinMinimumLength), String(Constants.Validation.PinMaximumLength)]
        )

        let newPinDifferenceRequirement = languageSettings.localized(
            "New PIN difference requirement", [codeType.name]
        )

        let pukLengthRequirement = languageSettings.localized(
            "PIN length requirement",
            [CodeType.puk.name, String(Constants.Validation.PukMinimumLength),
             String(Constants.Validation.PinMaximumLength)]
        )

        let pukCodeInfo = languageSettings.localized("PUK code info", [])

        switch (viewModel.step, pinAction, codeType) {
        case (.current, .change, _):
            return pinLengthRequirement
        case (.new, _, _), (.confirm, _, _):
            return "\(newPinDifferenceRequirement) \(pinLengthRequirement)"
        case (.current, .unblock, .pin1), (.current, .unblock, .pin2):
            return "\(pukLengthRequirement) \(pukCodeInfo)"
        default:
            return ""
        }
    }

    private var flowCodeType: String {
        switch (viewModel.step, pinAction, codeType) {
        case (.current, .change, _), (.new, _, _), (.confirm, _, _):
            return languageSettings.localized("PIN code", [codeType.name])
        case (.current, .unblock, .pin1), (.current, .unblock, .pin2):
            return languageSettings.localized("PIN code", [CodeType.puk.name])
        default:
            return ""
        }
    }

    private var pinMinimumLength: Int {
        switch codeType {
        case .pin1:
            return Constants.Validation.Pin1MinimumLength
        case .pin2:
            return Constants.Validation.Pin2MinimumLength
        case .puk:
            return Constants.Validation.PukMinimumLength
        }
    }

    private var buttonTitle: String {
        switch viewModel.step {
        case .confirm:
            return languageSettings.localized("Save new PIN", [codeType.name])
        default:
            return languageSettings.localized("Continue")
        }
    }

    init(
        pinAction: MyEidPinCodeAction,
        codeType: CodeType
    ) {
        self._viewModel = State(wrappedValue: Container.shared.myEidPinChangeViewModel((pinAction, codeType)))
        self.pinAction = pinAction
        self.codeType = codeType
    }

    var body: some View {
        TopBarContainer(
            title: nil,
            leftIcon: leftIcon,
            leftIconAccessibility: leftIconAccessibility,
            onLeftClick: {
                if viewModel.isFirstStep {
                    dismiss()
                } else {
                    viewModel.handleBackButton()
                }
            },
            content: {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(verbatim: flowTitle)
                                .font(typography.headlineSmall)
                                .foregroundStyle(theme.onSurface)
                                .padding(.top, Dimensions.Padding.MSPadding)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .center, spacing: Dimensions.Padding.XSPadding) {
                                Image("ic_m3_vpn_key_48pt_wght400")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: Dimensions.Icon.IconSizeM,
                                        height: Dimensions.Icon.IconSizeM
                                    )
                                    .foregroundStyle(theme.onBackground)
                                    .accessibilityHidden(true)

                                Text(verbatim: stepTitle)
                                    .font(typography.titleLarge)
                                    .foregroundStyle(theme.onSurface)
                            }
                            .padding(.top, Dimensions.Padding.XSPadding)
                            .padding(.bottom, Dimensions.Padding.LPadding)
                            .frame(maxWidth: .infinity)

                            FloatingLabelTextField(
                                title: flowCodeType,
                                placeholder: flowCodeType,
                                text: $viewModel.input,
                                isSecure: true,
                                isError: !errorMessage.isEmpty,
                                errorText: errorMessage,
                                keyboardType: .numberPad,
                                onDone: {
                                    if viewModel.step == .confirm || (
                                        viewModel.input.isEmpty || !errorMessage.isEmpty
                                    ) { return }

                                    Task { await viewModel.submit() }
                                }
                            )

                            Text(verbatim: flowDescription)
                                .font(typography.bodySmall)
                                .foregroundStyle(!errorMessage.isEmpty ? theme.error : theme.onSurface)
                                .padding(.vertical, Dimensions.Padding.MSPadding)
                        }
                    }

                    PrimaryButton(
                        text: buttonTitle,
                        isButtonEnabled: !viewModel.input.isEmpty && errorMessage.isEmpty,
                        action: {
                            Task { await viewModel.submit() }
                        }
                    )
                }
                .padding(Dimensions.Padding.SPadding)
                .frame(maxHeight: .infinity)
                .onChange(of: viewModel.isSuccess) { _, newValue in
                    if newValue {
                        switch pinAction {
                        case .change:
                            Toast.show(languageSettings.localized("PIN changed", [codeType.name]))
                        case .unblock:
                            Toast.show(languageSettings.localized("PIN unblocked", [codeType.name]))
                        }

                        dismiss()
                    }
                }
            }
        )
    }
}
