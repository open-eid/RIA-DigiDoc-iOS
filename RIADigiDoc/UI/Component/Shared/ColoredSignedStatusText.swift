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
import LibdigidocLibSwift

struct ColoredSignedStatusText: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let text: String
    let status: SignatureStatus

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
        TagBadge(
            text: text,
            tagBackgroundColor: tagBackgroundColor,
            tagContentColor: tagContentColor,
            additionalTextColor: additionalTextColor
        )
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
}
