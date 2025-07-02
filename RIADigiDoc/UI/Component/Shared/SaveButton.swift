import SwiftUI

struct SaveButton: View {
    @AppTheme private var theme

    @EnvironmentObject private var languageSettings: LanguageSettings

    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image("ic_m3_download_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onBackground)
                    .accessibilityLabel(languageSettings.localized("Save"))
            }
            .foregroundStyle(theme.onSurface)
            .padding(Dimensions.Padding.XXSPadding)
            .cornerRadius(Dimensions.Corner.MSCornerRadius)
        }
        .padding(.horizontal, Dimensions.Padding.MSPadding)
        .buttonStyle(PlainButtonStyle())
    }
}
