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
        .environmentObject(
            Container.shared.languageSettings()
        )
}
