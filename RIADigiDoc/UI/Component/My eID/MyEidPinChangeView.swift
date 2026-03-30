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
import IdCardLib
import CommonsLib

struct MyEidPinChangeView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings

    @AccessibilityFocusState private var flowTitleFocused: Bool
    @AccessibilityFocusState private var stepTitleFocused: Bool

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var viewModel: MyEidPinChangeViewModel
    @State private var pinAction: MyEidPinCodeAction
    @State private var codeType: CodeType
    private var personalCode: String

    private var inputErrorMessage: String {
        languageSettings.localized(
            viewModel.inputErrorMessage ?? "",
            viewModel.inputErrorMessageExtraArguments
        )
    }

    private var errorMessage: String {
        languageSettings.localized(
            viewModel.errorMessage ?? "",
            viewModel.errorMessageExtraArguments
        )
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
            [codeType.name, String(codeType.minimumLength), String(Constants.Validation.PinMaximumLength)]
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

    private var buttonTitle: String {
        switch viewModel.step {
        case .confirm:
            return languageSettings.localized("Save new PIN", [codeType.name])
        default:
            return languageSettings.localized("Continue")
        }
    }

    private var isInputError: Bool {
        viewModel.handleConfirmStepError()

        let pin = Array(viewModel.input.utf8)

        let currentCodeType = (pinAction == .unblock && viewModel.step == .current) ? .puk : codeType

        if !pin.isEmpty && viewModel.isPINLengthValid(for: currentCodeType, pin: pin) &&
            viewModel.step == .new {
                viewModel.verifyNewCode()
        }

        return !inputErrorMessage.isEmpty ||
        !viewModel.isPINLengthValid(for: currentCodeType, pin: pin)
    }

    private var nfcStringsUtil: NFCSessionStringsUtil {
        NFCSessionStringsUtil { key, args in
            languageSettings.localized(key, args)
        }
    }

    init(
        pinAction: MyEidPinCodeAction,
        codeType: CodeType,
        personalCode: String,
        actionMethod: ActionMethod
    ) {
        self._viewModel = State(
            wrappedValue: Container.shared.myEidPinChangeViewModel(
                (pinAction, codeType, personalCode, actionMethod)
            )
        )
        self.pinAction = pinAction
        self.codeType = codeType
        self.personalCode = personalCode
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
                                .accessibilityHeading(.h1)
                                .accessibilityAddTraits([.isHeader])
                                .accessibilityFocused($flowTitleFocused)
                                .accessibilitySortPriority(3)
                                .accessibilityRespondsToUserInteraction(true)

                            VStack(alignment: .center, spacing: Dimensions.Padding.XSPadding) {
                                Image("ic_m3_vpn_key_48pt_wght400")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: Dimensions.Icon.IconSizeM,
                                        height: Dimensions.Icon.IconSizeM
                                    )
                                    .foregroundStyle(theme.onSurfaceVariant)
                                    .accessibilityHidden(true)

                                Text(verbatim: stepTitle)
                                    .font(typography.titleLarge)
                                    .foregroundStyle(theme.onSurface)
                                    .accessibilityHeading(.h2)
                                    .accessibilityAddTraits([.isHeader])
                                    .accessibilityFocused($stepTitleFocused)
                                    .accessibilitySortPriority(2)
                            }
                            .padding(.top, Dimensions.Padding.XSPadding)
                            .padding(.bottom, Dimensions.Padding.LPadding)
                            .frame(maxWidth: .infinity)

                            VStack {
                                FloatingLabelTextField(
                                    title: flowCodeType,
                                    placeholder: flowCodeType,
                                    text: $viewModel.input,
                                    isSecure: true,
                                    isError: isInputError,
                                    errorText: inputErrorMessage,
                                    keyboardType: .numberPad,
                                    identifier: "pinInput",
                                    sortPriority: 0,
                                    spellOutCharacters: true,
                                    onDone: {
                                        if voiceOverEnabled || (viewModel.step == .confirm || (
                                            viewModel.input.isEmpty || !inputErrorMessage.isEmpty
                                        )) { return }

                                        Task { await viewModel.submit(nfcStringsUtil: nfcStringsUtil) }
                                    }
                                )

                                Text(verbatim: flowDescription)
                                    .font(typography.bodySmall)
                                    .foregroundStyle(isInputError ? theme.error : theme.onSurface)
                                    .padding(.vertical, Dimensions.Padding.MSPadding)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .accessibilitySortPriority(1)
                            }
                            .accessibilityElement(children: .contain)
                        }
                    }

                    PrimaryButton(
                        text: buttonTitle,
                        isButtonEnabled: !viewModel.input.isEmpty && !isInputError,
                        action: {
                            Task { await viewModel.submit(nfcStringsUtil: nfcStringsUtil) }
                        },
                        focusedField: nil,
                        currentFocus: .constant(nil)
                    )
                }
                .padding(Dimensions.Padding.SPadding)
                .frame(maxHeight: .infinity)
                .onAppear {
                    DispatchQueue.main.async {
                        flowTitleFocused = true
                    }
                }
                .onChange(of: viewModel.isSuccess) { _, newValue in
                    if newValue {
                        let message: String = {
                            switch pinAction {
                            case .change:
                                return languageSettings.localized("PIN changed", [codeType.name])
                            case .unblock:
                                return languageSettings.localized("PIN unblocked", [codeType.name])
                            }
                        }()

                        Toast.show(message, type: .success)
                        AccessibilityUtil.announceMessage(message)

                        dismiss()
                    }
                }
                .onChange(of: errorMessage, { _, newValue in
                    guard !newValue.isEmpty else { return }
                    Toast.show(newValue)
                    AccessibilityUtil.announceMessage(newValue)
                    if viewModel.isBlocked {
                        viewModel.resetErrors()
                        dismiss()
                    }
                    viewModel.resetErrors()
                })
                .onChange(of: viewModel.usbReaderStatus) { _, newValue in
                    if newValue != .sCardConnected {
                        dismiss()
                    }
                }
                .onChange(of: viewModel.step) { _, _ in
                    DispatchQueue.main.async {
                        stepTitleFocused = true
                    }
                }
            }
        )
    }

//    @ViewBuilder
//    private var inputGroup: some View {
//        VStack {
//            FloatingLabelTextField(
//                title: flowCodeType,
//                placeholder: flowCodeType,
//                text: $viewModel.input,
//                isSecure: true,
//                isError: isInputError,
//                errorText: inputErrorMessage,
//                keyboardType: .numberPad,
//                identifier: "pinInput",
//                sortPriority: 0,
//                spellOutCharacters: true,
//                onDone: {
//                    if voiceOverEnabled || (viewModel.step == .confirm || (
//                        viewModel.input.isEmpty || !inputErrorMessage.isEmpty
//                    )) { return }
//
//                    Task { await viewModel.submit(nfcStringsUtil: nfcStringsUtil) }
//                }
//            )
//
//            Text(verbatim: flowDescription)
//                .font(typography.bodySmall)
//                .foregroundStyle(isInputError ? theme.error : theme.onSurface)
//                .padding(.vertical, Dimensions.Padding.MSPadding)
//                .accessibilitySortPriority(1)
//        }
//    }
}
