import SwiftUI

struct TextModal: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var icon: String?
    var title: String
    var message: String
    var confirmButtonTitle: String = "OK"
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ModalContainer(
            icon: icon,
            title: title,
            confirmButtonTitle: confirmButtonTitle,
            onConfirm: onConfirm,
            onCancel: onCancel
        ) {
            Text(message)
                .font(typography.bodyMedium)
                .multilineTextAlignment(.leading)
                .foregroundStyle(theme.onSurfaceVariant)
                .padding(.leading, Dimensions.Padding.MSPadding)
                .padding(.trailing, Dimensions.Padding.LPadding)
        }
    }
}
