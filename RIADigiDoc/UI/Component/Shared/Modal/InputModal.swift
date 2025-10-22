import SwiftUI

struct InputModal: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme

    var icon: String?
    var title: String
    var placeholder: String
    @Binding var text: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ModalContainer(
            icon: icon,
            title: title,
            onConfirm: onConfirm,
            onCancel: onCancel
        ) {
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
                            Button {
                                text = ""
                            } label: {
                                Image("ic_m3_close_48pt_wght400")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .foregroundStyle(theme.onSurface)
                                    .padding(.trailing, Dimensions.Padding.XSPadding)
                                    .accessibilityLabel(languageSettings.localized("Close"))
                            }
                        }
                    }
                )
        }
    }
}
