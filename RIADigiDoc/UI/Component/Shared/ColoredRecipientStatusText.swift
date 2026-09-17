// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct ColoredRecipientStatusText: View {
    @AppTheme private var theme

    let text: String
    let status: RecipientDecryptionStatus

    private var tagBackgroundColor: Color {
        switch status {
        case .notEncrypted: return theme.surfaceVariant
        case .notEncryptedExpired, .expired, .expiredWithoutDate: return theme.errorContainer
        case .valid: return theme.successContainer
        }
    }

    private var tagContentColor: Color {
        switch status {
        case .notEncrypted: return theme.onSurface
        case .notEncryptedExpired, .expired, .expiredWithoutDate: return theme.onErrorContainer
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
