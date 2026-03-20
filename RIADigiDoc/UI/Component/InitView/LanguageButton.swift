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

struct LanguageButton<T: Equatable>: View {
    @AppTypography private var typography

    let title: String
    let onTap: () -> Void
    let accessibilityLabel: String
    let accessibilityInputLabel: String?

    private var accessibilityInputLabels: [String] {
        guard let accessibilityInputLabel else { return [accessibilityLabel] }
        return [accessibilityInputLabel, accessibilityLabel]
    }

    var body: some View {
        Button(
            action: onTap,
            label: {
                HStack(
                    spacing: Dimensions.Padding.SPadding,
                    content: {
                        Text(verbatim: title)
                            .font(typography.titleLarge)
                            .foregroundStyle(Color.white)

                        Image("ic_m3_arrow_forward_ios_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.white)
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .accessibilityHidden(true)
                    }
                )
            }
        )
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityInputLabels(accessibilityInputLabels)
    }
}
