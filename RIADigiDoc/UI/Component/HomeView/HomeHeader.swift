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
import CommonsLib
import FactoryKit

struct HomeHeader: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var body: some View {
        VStack(spacing: Dimensions.Padding.XXSPadding ) {
            LogoComponent()
            VersionComponent()
        }
        .padding(.vertical, Dimensions.Padding.XXSPadding)
        .padding(.horizontal, Dimensions.Padding.XSPadding)
    }
}

// MARK: - Logo Component
private struct LogoComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        HStack(spacing: Dimensions.Padding.XSPadding) {
            Image("image_id_ee")
                .resizable()
                .scaledToFit()
                .frame(width: Dimensions.Icon.IconSizeM)
                .accessibilityLabel(languageSettings.localized("DigiDoc"))

            Text(verbatim: languageSettings.localized("DigiDoc"))
                .font(typography.displayMedium)
                .foregroundStyle(theme.onSurface)
        }
    }
}

// MARK: - Version Component
private struct VersionComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        Text(verbatim: languageSettings.localized(
            "Main home version",
            [BundleUtil.getAppVersion()])
        )
        .font(typography.titleMedium)
        .foregroundStyle(theme.onSurfaceVariant)
    }
}

// MARK: - Preview
#Preview {
    HomeHeader()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
