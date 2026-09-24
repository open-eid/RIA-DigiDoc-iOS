// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
