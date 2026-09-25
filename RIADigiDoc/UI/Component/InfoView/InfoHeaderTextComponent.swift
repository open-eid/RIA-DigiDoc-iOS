// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import UtilsLib
import FactoryKit

struct InfoHeaderTextComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(alignment: .leading) {
            Text(languageSettings.localized("Main about ria digidoc title"))
                .font(typography.titleLarge)
                .foregroundStyle(theme.onSurface)
            Text(verbatim: languageSettings.localized(
                "Main about version title",
                [BundleUtil.getAppVersion()]
            ))
                .font(typography.bodyMedium)
                .foregroundStyle(theme.onSurfaceVariant)
            Text(languageSettings.localized("Main about info"))
                .font(typography.bodyMedium)
                .padding(.vertical, Dimensions.Padding.SPadding)
                .foregroundStyle(theme.onSurface)
            InfoHeaderHelpButton()
        }
    }
}

// MARK: - Preview
#Preview {
    InfoHeaderTextComponent()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
