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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(theme.onBackground.opacity(0.9))
                    .foregroundColor(theme.background)
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .padding(.horizontal, 20)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom)
                                .combined(with: .opacity),
                            removal: .move(edge: .bottom)
                                .combined(with: .opacity)
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: toast.isVisible)
                    .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .zIndex(999)
    }
}
