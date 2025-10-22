import SwiftUI

struct RemoveSignatureModalView: View {
    var title: String
    var message: String
    var confirmButtonTitle: String = "Remove"
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            // Make the background darker to focus on the dialog
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()

            TextModal(
                title: title,
                message: message,
                confirmButtonTitle: confirmButtonTitle,
                onConfirm: onConfirm,
                onCancel: onCancel
            )
        }
    }
}
