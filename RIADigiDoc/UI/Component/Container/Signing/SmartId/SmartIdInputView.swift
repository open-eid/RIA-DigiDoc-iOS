// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct SmartIdInputView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showCountryChooser: Bool = false

    @Binding var country: SmartIdCountry
    @Binding var personalCode: String
    @Binding var rememberMe: Bool
    @Binding var isSigningEnabled: Bool
    @Binding var personalCodeError: String?

    let onInputChange: () -> Void

    private var countryTitle: String {
        languageSettings.localized("Country title")
    }

    private var personalCodeTitle: String {
        languageSettings.localized("Personal code")
    }

    private var personalCodeErrorText: String {
        return languageSettings.localized(personalCodeError ?? "")
    }

    private var rememberMeLabel: String {
        languageSettings.localized("Remember me")
    }

    init(
        country: Binding<SmartIdCountry>,
        personalCode: Binding<String>,
        rememberMe: Binding<Bool>,
        isSigningEnabled: Binding<Bool>,
        personalCodeError: Binding<String?>,
        onInputChange: @escaping () -> Void
    ) {
        self._country = country
        self._personalCode = personalCode
        self._rememberMe = rememberMe
        self._isSigningEnabled = isSigningEnabled
        self._personalCodeError = personalCodeError
        self.onInputChange = onInputChange
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                    FloatingLabelTextField(
                        title: countryTitle,
                        placeholder: countryTitle,
                        text: .constant(languageSettings.localized(country.rawValue)),
                        isDropdown: true,
                        isDisabled: false,
                        onDropdownTap: {
                            showCountryChooser = true
                        },
                        identifier: "smartIdCountry"
                    )
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
                        identifier: "smartIdPersonalCode"
                    )
                    .onChange(of: personalCode) {
                        onInputChange()
                    }
                }
            }
            .padding(.vertical, Dimensions.Padding.ZeroPadding)

            VStack(spacing: Dimensions.Padding.ZeroPadding) {
                ToggleSection(
                    isOn: $rememberMe,
                    label: rememberMeLabel
                )
                .padding(.trailing, Dimensions.Padding.XSPadding)
                .padding(.vertical, Dimensions.Padding.ZeroPadding)

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
        .fullScreenCover(isPresented: $showCountryChooser) {
            ZStack {
                Color.black.opacity(Dimensions.Shadow.LOpacity)
                    .ignoresSafeArea()

                RadioButtonModal(
                    icon: nil,
                    title: languageSettings.localized("Choose country"),
                    options: SmartIdCountry.allCases,
                    titleKeyPath: \.rawValue,
                    selectedOption: country,
                    onConfirm: { chosenCountry in
                        self.country = chosenCountry
                        showCountryChooser = false
                    },
                    onCancel: {
                        showCountryChooser = false
                    }
                )
            }
            .presentationBackground(.clear)
        }
    }
}

#Preview {
    SmartIdInputView(
        country: .constant(SmartIdCountry.estonia),
        personalCode: .constant("456"),
        rememberMe: .constant(true),
        isSigningEnabled: .constant(true),
        personalCodeError: .constant(""),
        onInputChange: {}

    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
