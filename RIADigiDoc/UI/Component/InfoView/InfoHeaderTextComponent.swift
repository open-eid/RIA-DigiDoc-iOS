import SwiftUI
import CommonsLib
import FactoryKit

struct InfoHeaderTextComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        VStack(alignment: .leading) {
            Text(languageSettings.localized("Main about ria digidoc title"))
                .font(typography.titleLarge)
                .foregroundStyle(theme.onSurface)
            Text(String(
                 format: languageSettings.localized("Main about version title %@"),
                 BundleUtil.getBundleShortVersionString() + "." + BundleUtil.getBundleVersion()
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
        .environmentObject(
            Container.shared.languageSettings()
        )
}
