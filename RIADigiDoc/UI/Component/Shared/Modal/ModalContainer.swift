import SwiftUI

struct ModalContainer<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    var icon: String?
    var title: String
    var confirmButtonTitle: String = "OK"
    var onConfirm: () -> Void
    var onCancel: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
            HStack(alignment: .center) {
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onSurface)
                        .accessibilityHidden(true)
                }
            }

            Text(title)
                .foregroundStyle(theme.onSurface)
                .font(typography.headlineSmall)
                .padding(.leading, Dimensions.Padding.MSPadding)
                .padding(.trailing, Dimensions.Padding.LPadding)

            content

            HStack(spacing: Dimensions.Padding.MPadding) {
                Button(languageSettings.localized("Cancel")) { onCancel() }
                    .font(typography.labelLarge)
                    .foregroundStyle(theme.primary)

                Button(languageSettings.localized(confirmButtonTitle)) { onConfirm() }
                    .font(typography.labelLarge)
                    .foregroundStyle(theme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, Dimensions.Padding.MSPadding)
            .padding(.horizontal, Dimensions.Padding.XSPadding)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
                .fill(theme.surfaceContainerHighest)
        )
        .padding(.horizontal, Dimensions.Padding.XLPadding)
    }
}
