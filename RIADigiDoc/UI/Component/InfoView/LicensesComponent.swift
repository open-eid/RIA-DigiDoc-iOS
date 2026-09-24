// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct LicensesComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings

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
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
