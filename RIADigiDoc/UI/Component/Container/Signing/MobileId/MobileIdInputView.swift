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

    var onFieldChange: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
                FloatingLabelTextField(
                    title: languageSettings.localized("Country code and phone number"),
                    placeholder: phoneNumberPlaceholder,
                    text: $phoneNumber,
                    keyboardType: .phonePad,
                    showDashButton: true
                )
                .onChange(of: phoneNumber) { _ in
                    onFieldChange()
                }

                FloatingLabelTextField(
                    title: languageSettings.localized("Personal code"),
                    text: $personalCode,
                    keyboardType: .phonePad,
                    showDashButton: true
                )
                .onChange(of: personalCode) { _ in
                    onFieldChange()
                }
            }
            .padding(.vertical, Dimensions.Padding.ZeroPadding)

            VStack(spacing: Dimensions.Padding.ZeroPadding) {
                ToggleSection(isOn: $rememberMe, label: languageSettings.localized("Remember me"))
                    .padding(.trailing, Dimensions.Padding.XSPadding)
                    .padding(.vertical, Dimensions.Padding.ZeroPadding)

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

#Preview {
    MobileIdInputView(
        phoneNumber: .constant("123"),
        personalCode: .constant("456"),
        rememberMe: .constant(true),
        onFieldChange: {}
    )
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
