import SwiftUI

struct Toast {
    static func show(_ message: String, duration: TimeInterval = 5.0) {
        Task { @MainActor in
            ToastController.shared.show(message: message, duration: duration)
        }
    }
}
