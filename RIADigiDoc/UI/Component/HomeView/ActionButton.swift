import SwiftUI

struct ActionButton: View {
    @AppTheme private var theme

    let title: String
    let description: String
    let assetImageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Dimensions.Padding.SPadding) {
                AssetIconComponent(assetName: assetImageName)
                TextComponent(title: title, description: description)
                Spacer()
            }
            .padding(Dimensions.Padding.SPadding)
            .background(theme.surfaceContainerLow)
            .cornerRadius(Dimensions.Corner.MSCornerRadius)

            // MARK: - Elevated Style
            .shadow(
                color: Color.black.opacity(Dimensions.Shadow.SOpacity),
                radius: Dimensions.Shadow.radius,
                x: Dimensions.Shadow.xOffset,
                y: Dimensions.Shadow.yOffset
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Asset Icon Component
private struct AssetIconComponent: View {
    @AppTheme private var theme

    let assetName: String

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(theme.onPrimary)
            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
            .padding(Dimensions.Padding.XSPadding)
            .background(theme.primary)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

// MARK: - Text Component
private struct TextComponent: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            Text(title)
                .font(typography.titleMedium)
                .foregroundStyle(theme.onSurface)

            Text(description)
                .font(typography.bodyMedium)
                .foregroundStyle(theme.onSurface)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ActionButton(
            title: "Add Document",
            description: "Do something",
            assetImageName: "ic_m3_attach_file_48pt_wght400",
        ) {}
    }
    .padding()
}
