// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

@Observable
@MainActor
final class ToastController {
    static let shared = ToastController()

    var message: String?
    var isVisible = false
    var type: ToastType = .error

    private let showAnimation = Animation.interpolatingSpring(stiffness: 300, damping: 25)

    private let hideAnimation = Animation.easeInOut(duration: 0.3)

    func present(_ toast: ToastItem) async {
        message = toast.message
        type = toast.type

        withAnimation(showAnimation) {
            isVisible = true
        }

        try? await Task.sleep(for: .seconds(toast.duration))

        withAnimation(hideAnimation) {
            isVisible = false
        }

        try? await Task.sleep(for: .seconds(0.3))

        message = nil
    }
}
