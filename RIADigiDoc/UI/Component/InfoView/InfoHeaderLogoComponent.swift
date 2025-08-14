import SwiftUI
import FactoryKit

struct InfoHeaderLogoComponent: View {
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        VStack {
            Image("eesti_flag")
                .resizable()
                .scaledToFit()
                .frame(height: Dimensions.Icon.IconSizeM)
                .accessibilityLabel(languageSettings.localized("Main about 1 logo text"))

            Text(languageSettings.localized("Main about 1 logo text"))
                .font(typography.labelSmall)
                .multilineTextAlignment(.center)

            Image("eu_flag")
                .resizable()
                .scaledToFit()
                .frame(height: Dimensions.Icon.IconSizeM)
                .accessibilityLabel(languageSettings.localized("Main about 2 logo text"))

            Text(languageSettings.localized("Main about 2 logo text"))
                .font(typography.labelSmall)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Preview
#Preview {
    InfoHeaderLogoComponent()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
