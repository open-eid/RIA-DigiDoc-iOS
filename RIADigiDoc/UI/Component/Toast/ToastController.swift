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

@Observable
@MainActor
final class ToastController {
    static let shared = ToastController()

    var message: String?
    var isVisible = false

    private let showAnimation = Animation.interpolatingSpring(stiffness: 300, damping: 25)

    private let hideAnimation = Animation.easeInOut(duration: 0.3)

    func present(_ toast: ToastItem) async {
        message = toast.message

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
