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
        .environmentObject(
            Container.shared.languageSettings()
        )
}
