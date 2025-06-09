import SwiftUI

@MainActor
final class ToastController: ObservableObject {
    static let shared = ToastController()

    @Published var message: String?
    @Published var isVisible = false

    private var dismissTask: Task<Void, Never>?

    func show(message: String, duration: TimeInterval) {
        self.message = message

        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            isVisible = true
        }

        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isVisible = false
                }

                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    self.message = nil
                }
            }
        }
    }
}
