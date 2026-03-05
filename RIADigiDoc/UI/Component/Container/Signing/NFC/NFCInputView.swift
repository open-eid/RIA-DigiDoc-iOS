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

struct NFCInputView: View {
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

    @State private var showPinField: Bool
    @State private var isWebEidAuthenticating: Bool

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
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                    FloatingLabelTextField(
                        title: canNumberTitle,
                        placeholder: canNumberTitle,
                        text: $canNumber,
                        isError: !(canNumberError?.isEmpty ?? true),
                        errorText: canNumberError ?? "",
                        keyboardType: .numberPad
                    )
                    .onChange(of: canNumber) {
                        onInputChange()
                    }

                    Text(verbatim: canNumberLocationLabel)
                        .font(typography.labelMedium)
                        .foregroundStyle(theme.onSecondaryContainer)
                        .padding(.vertical, Dimensions.Padding.XXSPadding)
                }
            }
            .padding(.vertical, Dimensions.Padding.MPadding)

            if showPinField {
                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
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
                            Text(verbatim: languageSettings.localized("Remember me message"))
                                .font(typography.bodyMedium)
                                .foregroundStyle(theme.onSurfaceVariant)
                            Spacer()
                        }
                    }
                }
            }
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
