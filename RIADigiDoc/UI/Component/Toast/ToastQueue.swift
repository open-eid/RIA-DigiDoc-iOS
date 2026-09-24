// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

actor ToastQueue {
    static let shared = ToastQueue()

    private var queue: [ToastItem] = []
    private var isPresenting = false
    private var currentMessage: String?

    func enqueue(message: String, duration: TimeInterval, type: ToastType) {
        // Avoid consecutive duplicate messages
        if message == currentMessage || message == queue.last?.message { return }
        queue.append(ToastItem(message: message, duration: duration, type: type))
        processQueueIfNeeded()
    }

    private func processQueueIfNeeded() {
        guard !isPresenting, let next = queue.first else { return }

        isPresenting = true
        currentMessage = next.message
        queue.removeFirst()

        Task {
            await ToastController.shared.present(next)
            toastDidFinish()
        }
    }

    private func toastDidFinish() {
        isPresenting = false
        currentMessage = nil
        processQueueIfNeeded()
    }
}
