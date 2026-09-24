// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct ShareButton: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let iconName: String
    let label: String
    let accessibilityLabel: String

    var body: some View {
        HStack(spacing: Dimensions.Padding.XSPadding) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(theme.onSurface)
                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                .accessibilityHidden(true)

            Text(verbatim: label)
                .foregroundStyle(theme.onSurface)
                .font(typography.bodyLarge)
                .accessibilityHidden(true)
        }
        .padding(Dimensions.Padding.MSPadding)
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Corner.MSCornerRadius)
                .fill(theme.surfaceContainerHigh)
                .shadow(
                    color: theme.onSurfaceVariant.opacity(Dimensions.Shadow.SOpacity),
                    radius: Dimensions.Shadow.radius,
                    x: Dimensions.Shadow.xOffset,
                    y: Dimensions.Shadow.yOffset
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("signedContainerShareButton")
    }
}
