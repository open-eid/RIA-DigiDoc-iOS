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

struct ConfirmModalView: View {
    var title: String
    var message: String
    var isConfirmButtonVisible: Bool = true
    var messageAccessibility: String = ""
    var confirmButtonTitle: String = "Remove"
    var cancelButtonTitle: String = "Cancel"
    var confirmButtonAccessibility: String?
    var cancelButtonAccessibility: String?
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            // Make the background darker to focus on the dialog
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            TextModal(
                title: title,
                message: message,
                isConfirmButtonVisible: isConfirmButtonVisible,
                messageAccessibility: messageAccessibility,
                confirmButtonTitle: confirmButtonTitle,
                cancelButtonTitle: cancelButtonTitle,
                confirmButtonAccessibility: confirmButtonAccessibility,
                cancelButtonAccessibility: cancelButtonAccessibility,
                onConfirm: onConfirm,
                onCancel: onCancel
            )
            .accessibilityAddTraits(.isModal)
            .accessibilityElement(children: .contain)
        }
    }
}
