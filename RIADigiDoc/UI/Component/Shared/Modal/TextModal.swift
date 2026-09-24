// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct TextModal: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var icon: String?
    var title: String
    var message: String
    var isConfirmButtonVisible: Bool = true
    var messageAccessibility: String = ""
    var confirmButtonTitle: String = "OK"
    var cancelButtonTitle: String = "Cancel"
    var confirmButtonAccessibility: String?
    var cancelButtonAccessibility: String?
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ModalContainer(
            icon: icon,
            title: title,
            isConfirmButtonVisible: isConfirmButtonVisible,
            confirmButtonTitle: confirmButtonTitle,
            cancelButtonTitle: cancelButtonTitle,
            confirmButtonAccessibility: confirmButtonAccessibility,
            cancelButtonAccessibility: cancelButtonAccessibility,
            onConfirm: onConfirm,
            onCancel: onCancel
        ) {
            Text(verbatim: message)
                .font(typography.bodyMedium)
                .multilineTextAlignment(.leading)
                .foregroundStyle(theme.onSurfaceVariant)
                .accessibilityLabel(messageAccessibility.isEmpty ? message : messageAccessibility)
        }
        .accessibilityAddTraits([.isModal])
    }
}
