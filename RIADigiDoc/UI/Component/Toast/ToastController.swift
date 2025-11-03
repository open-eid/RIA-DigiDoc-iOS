/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import SwiftUI

@MainActor
final class ToastController: ObservableObject {
    static let shared = ToastController()

    @Published var message: String?
    @Published var isVisible = false

    private var dismissTask: Task<Void, Never>?

    func show(message: String, duration: TimeInterval) {
        guard !isVisible else { return }
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
