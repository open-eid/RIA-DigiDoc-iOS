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

struct InfoHeaderHelpButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.openURL) var openURL
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        Button(
            action: {
                if let url = URL(string: languageSettings.localized("Main home menu help url")) {
                    openURL(url)
                }
            },
            label: {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Image("ic_m3_open_in_new_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onPrimary)
                        .accessibilityHidden(true)
                    Text(languageSettings.localized("Main about help center"))
                        .font(typography.labelMedium)
                        .foregroundStyle(theme.onPrimary)

                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.XSPadding)
                .background(theme.primary)
                .cornerRadius(Dimensions.Corner.MCornerRadius)
            }
        )
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    InfoHeaderHelpButton()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
