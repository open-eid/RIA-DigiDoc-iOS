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
    @AppTypography private var typography

    let text: String
    let status: SignatureStatus

    private var isSignatureValidOrWarning: Bool {
        status == .valid || status == .warning || status == .nonQSCD
    }

    private var tagBackgroundColor: Color {
        isSignatureValidOrWarning ? AppColors.Green50 : AppColors.Red50
    }

    private var tagContentColor: Color {
        isSignatureValidOrWarning ? AppColors.Green700 : AppColors.Red800
    }

    private var additionalTextColor: Color {
        switch status {
        case .valid:
            return AppColors.Red800
        default:
            return AppColors.Yellow800
        }
    }

    var body: some View {
        let parts = text.components(separatedBy: " (")
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center) {
                Text(parts[0])
                    .font(typography.bodyMedium)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Dimensions.Padding.XSPadding)
                    .padding(.vertical, Dimensions.Padding.XXSPadding)
                    .background(tagBackgroundColor)
                    .foregroundStyle(tagContentColor)
                    .clipShape(Capsule())

                if parts.count > 1 {
                    Text(verbatim: "(\(parts[1])")
                        .font(typography.bodyMedium)
                        .foregroundStyle(additionalTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading) {
                Text(parts[0])
                    .font(typography.bodyMedium)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Dimensions.Padding.XSPadding)
                    .padding(.vertical, Dimensions.Padding.XXSPadding)
                    .background(tagBackgroundColor)
                    .foregroundStyle(tagContentColor)
                    .clipShape(Capsule())

                if parts.count > 1 {
                    Text(verbatim: "(\(parts[1])")
                        .font(typography.bodyMedium)
                        .foregroundStyle(additionalTextColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
}
