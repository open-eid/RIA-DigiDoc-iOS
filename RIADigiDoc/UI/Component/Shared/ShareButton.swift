import SwiftUI

struct ShareButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let iconName: String
    let label: String
    let accessibilityLabel: String
    let onClick: () -> Void

    var body: some View {
        // Set as button on iOS 15 only as ShareLink handles sharing on iOS 16+.
        // Button would overwrite ShareLink's action
        Group {
            if #available(iOS 16.0, *) {
                content
            } else {
                Button(action: onClick, label: {
                    content
                })
            }
        }
    }

    private var content: some View {
        HStack(spacing: Dimensions.Padding.XSPadding) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(theme.onSurface)
                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                .accessibilityHidden(true)

            Text(verbatim: label)
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
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("signedContainerShareButton")
    }
}
