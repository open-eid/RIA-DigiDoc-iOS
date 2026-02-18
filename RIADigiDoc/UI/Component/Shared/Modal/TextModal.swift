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

struct TextModal: View {
    @AppTheme private var theme
    @AppTypography private var typography

    var icon: String?
    var title: String
    var message: String
    var isConfirmButtonVisible: Bool = true
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
            Text(message)
                .font(typography.bodyMedium)
                .multilineTextAlignment(.leading)
                .foregroundStyle(theme.onSurfaceVariant)
        }
    }
}
