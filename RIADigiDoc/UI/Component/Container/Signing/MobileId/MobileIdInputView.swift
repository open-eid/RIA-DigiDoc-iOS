// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct MobileIdInputView: View {
    @Environment(LanguageSettings.self) private var languageSettings

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

    private var personalCodeTitle: String {
        languageSettings.localized("Personal code")
    }

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
                        showDashButton: true,
                        identifier: "mobileIdCountryCodeAndPhoneNumber"
                    )
                    .onChange(of: phoneNumber) {
                        onInputChange()
                    }
                }

                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                    FloatingLabelTextField(
                        title: personalCodeTitle,
                        placeholder: personalCodeTitle,
                        text: $personalCode,
                        isError: !personalCodeErrorText.isEmpty,
                        errorText: personalCodeErrorText,
                        keyboardType: .phonePad,
                        showDashButton: true,
                        identifier: "mobileIdPersonalCode"
                    )
                    .onChange(of: personalCode) {
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
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
