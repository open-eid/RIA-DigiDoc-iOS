import SwiftUI

struct Dialog: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    var icon: String?
    var title: String
    var placeholder: String
    @Binding var text: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: Dimensions.Padding.MPadding) {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurface)
                    .padding(.trailing, Dimensions.Padding.SPadding)
                    .accessibilityHidden(true)
            }

            Text(title)
                .foregroundStyle(theme.onSurface)
                .font(typography.headlineSmall)

            TextField(placeholder, text: $text)
                .padding(.vertical, Dimensions.Padding.MSPadding)
                .padding(.leading, Dimensions.Padding.MSPadding)
                .padding(.trailing, Dimensions.Padding.LPadding)
                .background(
                    RoundedRectangle(cornerRadius: Dimensions.Corner.XXSCornerRadius)
                        .stroke(theme.primary, lineWidth: Dimensions.Height.XSBorder)
                )
                .overlay(
                    HStack {
                        Spacer()
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }, label: {
                                Image("ic_m3_close_48pt_wght400")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .foregroundStyle(theme.onSurface)
                                    .padding(.trailing, Dimensions.Padding.XSPadding)
                                    .accessibilityLabel(languageSettings.localized("Close"))
                            })
                        }
                    }
                )
                .padding(.horizontal, Dimensions.Padding.XSPadding)

            HStack(spacing: Dimensions.Padding.MPadding) {
                Button(languageSettings.localized("Cancel")) {
                    onCancel()
                }
                .font(typography.labelLarge)
                .foregroundStyle(theme.primary)

                Button(languageSettings.localized("Change")) {
                    onConfirm()
                }
                .font(typography.labelLarge)
                .foregroundStyle(theme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, Dimensions.Padding.MSPadding)
            .padding(.horizontal, Dimensions.Padding.XSPadding)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
            .fill(theme.surfaceContainerHighest)
        )
        .padding(.horizontal, Dimensions.Padding.XLPadding)
    }
}
