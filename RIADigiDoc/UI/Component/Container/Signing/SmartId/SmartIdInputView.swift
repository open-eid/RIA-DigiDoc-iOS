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

struct SmartIdInputView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showCountryChooser: Bool = false

    @Binding var country: SmartIdCountry
    @Binding var personalCode: String
    @Binding var rememberMe: Bool
    @Binding var isSigningEnabled: Bool
    @Binding var personalCodeError: String?

    let onInputChange: () -> Void

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
                        title: languageSettings.localized("Country title"),
                        text: .constant(languageSettings.localized(country.rawValue)),
                        isDropdown: true,
                        isDisabled: false,
                        onDropdownTap: {
                            showCountryChooser = true
                        }
                    )
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
            .clearPresentationBackground()
        }
    }
}

// TODO: Remove in iOS 17 minimum version
// Workaround for iOS 15
struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_: UIView, context _: Context) {}
}

extension View {
    func clearPresentationBackground() -> some View {
        if #available(iOS 16.4, *) {
            return AnyView(self.presentationBackground(.clear))
        } else {
            return AnyView(self.background(BackgroundClearView()))
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
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
