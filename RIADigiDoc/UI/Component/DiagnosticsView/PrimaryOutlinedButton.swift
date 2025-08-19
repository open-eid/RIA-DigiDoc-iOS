import SwiftUI
import FactoryKit

struct PrimaryOutlinedButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let text: String
    let assetImageName: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let image = assetImageName {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.primary)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .accessibilityHidden(true)
                }
                Text(text)
                    .foregroundStyle(theme.primary)
                    .font(typography.labelLarge)
                    .frame(height: Dimensions.Icon.IconSizeXXS)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Dimensions.Padding.XSPadding)
            .background(
                Capsule()
                    .stroke(theme.outline, lineWidth: Dimensions.Height.XSBorder)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Dimensions.Padding.XSPadding) {
            PrimaryOutlinedButton(
                text: "button without icon",
                assetImageName: nil,
                action: {}
            )
            PrimaryOutlinedButton(
                text: "button with icon",
                assetImageName: "ic_m3_download_48pt_wght400",
                action: {}
            )
        }
        .environmentObject(
            Container.shared.languageSettings()
        )
}
