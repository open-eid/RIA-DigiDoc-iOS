/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

struct ColoredRecipientStatusText: View {
    @AppTheme private var theme

    let text: String
    let status: RecipientDecryptionStatus

    private var tagBackgroundColor: Color {
        switch status {
        case .notEncrypted: return theme.surfaceVariant
        case .notEncryptedExpired, .expired: return theme.errorContainer
        case .valid: return theme.successContainer
        }
    }

    private var tagContentColor: Color {
        switch status {
        case .notEncrypted: return theme.onSurface
        case .notEncryptedExpired, .expired: return theme.onErrorContainer
        case .valid: return theme.onSuccessContainer
        }
    }

    var body: some View {
        TagBadge(
            text: text,
            tagBackgroundColor: tagBackgroundColor,
            tagContentColor: tagContentColor,
            additionalTextColor: theme.onSurfaceVariant
        )
    }
}

#Preview {
    ColoredRecipientStatusText(
        text: "Expires on 12.03.2028",
        status: .notEncrypted
    )

    ColoredRecipientStatusText(
        text: "Expired on 04.01.2024",
        status: .notEncryptedExpired
    )

    ColoredRecipientStatusText(
        text: "Decryption until 12.09.2026",
        status: .valid
    )

    ColoredRecipientStatusText(
        text: "Decryption expired 04.01.2024",
        status: .expired
    )
}
