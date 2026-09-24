// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
                .allowsHitTesting(true)

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
        .accessibilityAddTraits(.isModal)
    }
}
