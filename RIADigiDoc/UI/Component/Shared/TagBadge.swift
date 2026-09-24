// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import LibdigidocLibSwift

struct TagBadge: View {
    @AppTypography private var typography

    let text: String
    let tagBackgroundColor: Color
    let tagContentColor: Color
    let additionalTextColor: Color

    init(
        text: String,
        tagBackgroundColor: Color,
        tagContentColor: Color,
        additionalTextColor: Color = .clear
    ) {
        self.text = text
        self.tagBackgroundColor = tagBackgroundColor
        self.tagContentColor = tagContentColor
        self.additionalTextColor = additionalTextColor
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
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
    TagBadge(
        text: "TagBadge",
        tagBackgroundColor: AppColors.light.successContainer,
        tagContentColor: AppColors.light.onSuccessContainer,
        additionalTextColor: AppColors.light.warningContainer
    )
}
