import SwiftUI

struct ShareButtonBottomBar: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    let iconName: String
    let label: String
    let accessibilityLabel: String
    let onShare: () -> Void

    var body: some View {
        HStack {
            Spacer()

            Button(action: onShare) {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.onSurface)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .accessibilityHidden(true)

                    Text(label)
                        .foregroundStyle(theme.onSurface)
                        .font(typography.bodyLarge)
                        .accessibilityHidden(true)
                }
                .padding(Dimensions.Padding.MSPadding)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.Corner.MSCornerRadius)
                        .fill(theme.surfaceContainerHigh)
                        .shadow(
                            color: theme.onBackground.opacity(Dimensions.Shadow.SOpacity),
                            radius: Dimensions.Shadow.radius,
                            x: Dimensions.Shadow.xOffset,
                            y: Dimensions.Shadow.yOffset
                        )
                )
            }
            .accessibilityLabel(accessibilityLabel)
            .accessibilityIdentifier("signedContainerShareButton")
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
        .padding(.top, Dimensions.Padding.XSPadding)
        .padding(.bottom, Dimensions.Padding.SPadding)
        .accessibilityIdentifier("signedContainerContainer")
    }
}
