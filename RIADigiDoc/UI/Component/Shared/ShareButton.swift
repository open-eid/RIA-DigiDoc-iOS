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
