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

struct MobileIdInputView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    private let phoneNumberPlaceholder = "372XXXXXXXX"

    @Binding var phoneNumber: String
    @Binding var personalCode: String
    @Binding var rememberMe: Bool
    @Binding var isSigningEnabled: Bool
    @Binding var countryCodeAndPhoneError: String?
    @Binding var personalCodeError: String?

    let onInputChange: () -> Void

    private var countryCodeAndPhoneErrorText: String {
        return languageSettings.localized(countryCodeAndPhoneError ?? "")
    }

    private var personalCodeErrorText: String {
        return languageSettings.localized(personalCodeError ?? "")
    }

    private var rememberMeLabel: String {
        languageSettings.localized("Remember me")
    }

    init(
        phoneNumber: Binding<String>,
        personalCode: Binding<String>,
        rememberMe: Binding<Bool>,
        isSigningEnabled: Binding<Bool>,
        countryCodeAndPhoneError: Binding<String?>,
        personalCodeError: Binding<String?>,
        onInputChange: @escaping () -> Void
    ) {
        self._phoneNumber = phoneNumber
        self._personalCode = personalCode
        self._rememberMe = rememberMe
        self._isSigningEnabled = isSigningEnabled
        self._countryCodeAndPhoneError = countryCodeAndPhoneError
        self._personalCodeError = personalCodeError
        self.onInputChange = onInputChange
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                    FloatingLabelTextField(
                        title: languageSettings.localized("Country code and phone number"),
                        placeholder: phoneNumberPlaceholder,
                        text: $phoneNumber,
                        isError: !countryCodeAndPhoneErrorText.isEmpty,
                        errorText: countryCodeAndPhoneErrorText,
                        keyboardType: .phonePad,
                        showDashButton: true
                    )
                    .onChange(of: phoneNumber) { _ in
                        onInputChange()
                    }
                }

                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                    FloatingLabelTextField(
                        title: languageSettings.localized("Personal code"),
                        text: $personalCode,
                        isError: !personalCodeErrorText.isEmpty,
                        errorText: personalCodeErrorText,
                        keyboardType: .phonePad,
                        showDashButton: true
                    )
                    .onChange(of: personalCode) { _ in
                        onInputChange()
                    }
                }
            }
            .padding(.vertical, Dimensions.Padding.ZeroPadding)

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

#Preview {
    MobileIdInputView(
        phoneNumber: .constant("123"),
        personalCode: .constant("456"),
        rememberMe: .constant(true),
        isSigningEnabled: .constant(true),
        countryCodeAndPhoneError: .constant(""),
        personalCodeError: .constant(""),
        onInputChange: {}

    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
