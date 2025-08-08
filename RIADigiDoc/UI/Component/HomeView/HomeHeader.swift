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
            
            Text(languageSettings.localized("DigiDoc"))
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
        Text(String(
                 format: languageSettings.localized("Main home version %@"),
                 BundleUtil.getBundleShortVersionString() + "." + BundleUtil.getBundleVersion()
             ))
            .font(typography.titleMedium)
            .foregroundStyle(theme.onSurfaceVariant)
    }
}

// MARK: - Preview
#Preview {
    HomeHeader()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
