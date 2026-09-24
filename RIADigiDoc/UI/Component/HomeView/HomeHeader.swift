// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import UtilsLib
import FactoryKit

struct HomeHeader: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(spacing: Dimensions.Padding.XXSPadding ) {
            logoComponent
            versionComponent
        }
        .padding(.vertical, Dimensions.Padding.XXSPadding)
        .padding(.horizontal, Dimensions.Padding.XSPadding)
    }

    private var logoText: String {
        languageSettings.localized("DigiDoc")
    }

    @ViewBuilder
    private var logoComponent: some View {
        HStack(spacing: Dimensions.Padding.XSPadding) {
            Image("image_id_ee")
                .resizable()
                .scaledToFit()
                .frame(width: Dimensions.Icon.IconSizeM)

            Text(verbatim: logoText)
                .font(typography.displayMedium)
                .foregroundStyle(theme.onSurface)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(logoText)
        .accessibilityAddTraits(.isImage)
    }

    @ViewBuilder
    private var versionComponent: some View {
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
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
