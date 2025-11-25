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

struct LicensesComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    private let packages: [DependencyLicense] = DependencyLicenses.getPackages()

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
            Text(languageSettings.localized("Main about licenses title"))
                .font(typography.titleLarge)
                .padding(.bottom, Dimensions.Padding.XSPadding)
                .foregroundStyle(theme.onSurface)
                .accessibilityHeading(.h1)
                .accessibilityAddTraits([.isHeader])

            ForEach(packages, id: \.id) { pkg in
                SingleLicenseButton(package: pkg)
                Divider()
            }
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
        .padding(.vertical, Dimensions.Padding.LPadding)
        .background(theme.surface)
    }
}

// MARK: - Preview
#Preview {
    LicensesComponent()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
