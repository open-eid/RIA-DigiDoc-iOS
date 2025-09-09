import FactoryKit
import SwiftUI

struct UnsignedBottomBarView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    let leftButtonIconName: String
    let leftButtonLabel: String
    let leftButtonAccessibilityLabel: String
    let leftButtonAction: () -> Void

    let rightButtonIconName: String
    let rightButtonLabel: String
    let rightButtonAccessibilityLabel: String
    let rightButtonAction: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                // TODO: Add file action
            }, label: {
                HStack(spacing: Dimensions.Padding.XSPadding, content: {
                    Image(leftButtonIconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.onSurface)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .accessibilityHidden(true)

                    Text(languageSettings.localized(leftButtonLabel))
                        .foregroundStyle(theme.primary)
                        .font(typography.titleMedium)
                })
                .foregroundStyle(theme.surfaceContainer)
            })

            Spacer()

            Button(action: {
                // TODO: Add sign action
            }, label: {
                HStack(spacing: Dimensions.Padding.XSPadding) {
                    Image(rightButtonIconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.onSurface)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .accessibilityHidden(true)

                    Text(languageSettings.localized(rightButtonLabel))
                        .foregroundStyle(theme.primary)
                        .font(typography.titleMedium)
                }
                .padding(.horizontal, Dimensions.Padding.MPadding)
                .padding(.vertical, Dimensions.Padding.XSPadding)
                .background(
                    Capsule()
                        .stroke(theme.outline, lineWidth: Dimensions.Height.XSBorder)
                )
            })
            .foregroundStyle(theme.surfaceContainer)
        }
        .padding(Dimensions.Padding.SPadding)
        .background(theme.surfaceContainer)
    }
}

#Preview {
    UnsignedBottomBarView(
        leftButtonIconName: "ic_m3_add_48pt_wght400",
        leftButtonLabel: "Add more files",
        leftButtonAccessibilityLabel: "Add more files",
        leftButtonAction: {},

        rightButtonIconName: "ic_m3_stylus_note_48pt_wght400",
        rightButtonLabel: "Sign",
        rightButtonAccessibilityLabel: "Sign",
        rightButtonAction: {}
    )
        .environmentObject(Container.shared.languageSettings())
}
