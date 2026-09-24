// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import nfclib

struct NFCInputView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @Binding var canNumber: String
    @Binding var rememberMe: Bool
    @Binding var isActionEnabled: Bool
    @Binding var canNumberError: String?
    @Binding var pinNumber: String
    @Binding var pinError: String?

    var pinType: CodeType?
    let onInputChange: () -> Void

    private let showPinField: Bool
    private let isWebEidAuthenticating: Bool

    let isWebEid: Bool

    private var canNumberTitle: String {
        languageSettings.localized("CAN number")
    }

    private var pinNumberTitle: String {
        languageSettings.localized("PIN code", [pinType?.name ?? ""])
    }

    private var canNumberLocationLabel: String {
        languageSettings.localized("CAN number location")
    }

    private var rememberMeLabel: String {
        languageSettings.localized("Remember me")
    }

    private var rememberMeMessage: String {
        languageSettings.localized(isWebEid ? "rememberMeMessageWebEid" : "Remember me message")
    }

    init(
        canNumber: Binding<String>,
        rememberMe: Binding<Bool>,
        isActionEnabled: Binding<Bool>,
        canNumberError: Binding<String?>,
        pinNumber: Binding<String>,
        pinError: Binding<String?>,
        pinType: CodeType?,
        onInputChange: @escaping () -> Void,
        showPinField: Bool = true,
        isWebEidAuthenticating: Bool = false,
        isWebEid: Bool = false,
    ) {
        self._canNumber = canNumber
        self._rememberMe = rememberMe
        self._isActionEnabled = isActionEnabled
        self._canNumberError = canNumberError
        self._pinNumber = pinNumber
        self._pinError = pinError
        self.pinType = pinType
        self.onInputChange = onInputChange
        self.showPinField = showPinField
        self.isWebEidAuthenticating = isWebEidAuthenticating
        self.isWebEid = isWebEid
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                // Allow keyboard to focus on input fields
                // but have custom sort priority (contain to VStack) for these elements only with VoiceOver
                if voiceOverEnabled {
                    nfcInputFields
                        .accessibilityElement(children: .contain)
                } else {
                    nfcInputFields
                }
            }
            .padding(.bottom, Dimensions.Padding.MPadding)

            if showPinField {
                VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                    FloatingLabelTextField(
                        title: pinNumberTitle,
                        placeholder: pinNumberTitle,
                        text: $pinNumber,
                        isSecure: true,
                        isError: !(pinError?.isEmpty ?? true),
                        errorText: pinError ?? "",
                        keyboardType: .numberPad
                    )
                    .onChange(of: pinNumber) {
                        onInputChange()
                    }
                }
            }
            if !isWebEidAuthenticating {
                VStack(spacing: Dimensions.Padding.ZeroPadding) {
                    ToggleSection(isOn: $rememberMe, label: languageSettings.localized("Remember me"))
                        .padding(.trailing, Dimensions.Padding.XSPadding)
                        .padding(.vertical, Dimensions.Padding.ZeroPadding)
                        .accessibilityLabel(Text(verbatim: "\(rememberMeLabel) \(rememberMe)"))

                    if rememberMe {
                        HStack {
                            Text(verbatim: rememberMeMessage)
                                .font(typography.bodyMedium)
                                .foregroundStyle(theme.onSurfaceVariant)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var nfcInputFields: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
            FloatingLabelTextField(
                title: canNumberTitle,
                placeholder: canNumberTitle,
                text: $canNumber,
                isError: !(canNumberError?.isEmpty ?? true),
                errorText: canNumberError ?? "",
                keyboardType: .numberPad,
                sortPriority: 0
            )
            .onChange(of: canNumber) {
                onInputChange()
            }

            Text(verbatim: canNumberLocationLabel)
                .font(typography.labelMedium)
                .foregroundStyle(theme.onSecondaryContainer)
                .padding(.top, Dimensions.Padding.XXSPadding)
                .accessibilitySortPriority(1)
        }
    }
}

#Preview {
    NFCInputView(
        canNumber: .constant("123456"),
        rememberMe: .constant(true),
        isActionEnabled: .constant(true),
        canNumberError: .constant(nil),
        pinNumber: .constant("123"),
        pinError: .constant(nil),
        pinType: CodeType.pin2,
        onInputChange: {},
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
