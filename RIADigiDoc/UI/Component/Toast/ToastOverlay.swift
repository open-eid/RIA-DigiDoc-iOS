import SwiftUI

struct ToastOverlay: View {
    @ObservedObject private var toast = ToastController.shared

    @AppTheme private var theme

    var body: some View {
        VStack {
            Spacer()

            if toast.isVisible, let message = toast.message {
                Text(message)
                    .lineLimit(2)
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                    .padding(.vertical, Dimensions.Padding.MSPadding)
                    .background(theme.onBackground.opacity(0.9))
                    .foregroundStyle(theme.background)
                    .cornerRadius(Dimensions.Corner.MSCornerRadius)
                    .shadow(radius: Dimensions.Corner.XXSCornerRadius)
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom)
                                .combined(with: .opacity),
                            removal: .move(edge: .bottom)
                                .combined(with: .opacity)
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: toast.isVisible)
                    .padding(.bottom, Dimensions.Padding.LPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .zIndex(999)
    }
}
