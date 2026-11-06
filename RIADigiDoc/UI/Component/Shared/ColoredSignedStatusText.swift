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
    var isPastArchiveTimestampValidUntil: Bool = false

    private var isSignatureValidOrWarning: Bool {
        SignatureUtil.isValidOrWarning(status)
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
            return theme.onWarningContainer
        default:
            return theme.onErrorContainer
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
            if let archiveText = archiveTimestampText {
                let isExpired = SignatureUtil.isArchiveTimestampExpired(
                    status: status,
                    isPastValidUntil: isPastArchiveTimestampValidUntil
                )
                TagBadge(
                    text: archiveText,
                    tagBackgroundColor: isExpired ? theme.errorContainer : theme.successContainer,
                    tagContentColor: isExpired ? theme.onErrorContainer : theme.onSuccessContainer
                )
            }

            if SignatureUtil.showsStatusBadge(status: status, hasArchiveTimestamp: archiveTimestampText != nil) {
                TagBadge(
                    text: text,
                    tagBackgroundColor: tagBackgroundColor,
                    tagContentColor: tagContentColor,
                    additionalTextColor: additionalTextColor
                )
            }
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

    ColoredSignedStatusText(
        text: "Signature is unknown",
        status: .unknown,
        archiveTimestampText: "Archive timestamp"
    )
}
