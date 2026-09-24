// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import LibdigidocLibSwift

struct ColoredSignedStatusText: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let text: String
    let status: SignatureStatus
    var archiveTimestampText: String?
    var isArchiveTimestampExpired: Bool = false

    private var isSignatureValidOrWarning: Bool {
        status == .valid || status == .warning || status == .nonQSCD
    }

    private var tagBackgroundColor: Color {
        isSignatureValidOrWarning ? theme.successContainer : theme.errorContainer
    }

    private var tagContentColor: Color {
        isSignatureValidOrWarning ? theme.onSuccessContainer : theme.onErrorContainer
    }

    private var additionalTextColor: Color {
        switch status {
        case .valid:
            return theme.errorContainer
        default:
            return theme.warning
        }
    }

    var body: some View {
        if let archiveText = archiveTimestampText {
            TagBadge(
                text: archiveText,
                tagBackgroundColor: isArchiveTimestampExpired ? theme.errorContainer : theme.successContainer,
                tagContentColor: isArchiveTimestampExpired ? theme.onErrorContainer : theme.onSuccessContainer
            )
        } else {
            TagBadge(
                text: text,
                tagBackgroundColor: tagBackgroundColor,
                tagContentColor: tagContentColor,
                additionalTextColor: additionalTextColor
            )
        }
    }
}

#Preview {
    ColoredSignedStatusText(
        text: "Signature is valid",
        status: .valid
    )

    ColoredSignedStatusText(
        text: "Signature is valid (warnings)",
        status: .warning
    )

    ColoredSignedStatusText(
        text: "Signature is unknown",
        status: .unknown
    )

    ColoredSignedStatusText(
        text: "Signature is valid",
        status: .valid,
        archiveTimestampText: "Archive timestamp"
    )
}
