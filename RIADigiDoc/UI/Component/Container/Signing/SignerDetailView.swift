// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct SignatureDataItem {
    let title: String
    let value: String
    let extraIcon: String?

    init(title: String, value: String, extraIcon: String? = nil) {
        self.title = title
        self.value = value
        self.extraIcon = extraIcon
    }
}

struct SignerDetailView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let signatureDataItem: SignatureDataItem

    var body: some View {
        VStack {
            Grid(horizontalSpacing: Dimensions.Padding.XXSPadding, verticalSpacing: Dimensions.Padding.XXSPadding) {
                GridRow {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                        Text(verbatim: signatureDataItem.title)
                            .font(typography.labelSmall)
                            .foregroundStyle(theme.onSurfaceVariant)
                        Text(verbatim: signatureDataItem.value)
                            .foregroundStyle(theme.onSurface)
                            .font(typography.bodyLarge)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let extraIcon = signatureDataItem.extraIcon {
                        Image(extraIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onSurfaceVariant)
                            .accessibilityHidden(true)
                    }
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, Dimensions.Padding.XSPadding)
            .accessibilityElement(children: .combine)

            Divider()
        }
        .padding(.horizontal, Dimensions.Padding.SPadding)
    }
}

#Preview {
    SignerDetailView(
        signatureDataItem:
            SignatureDataItem(
                title: "Signer's certificate issuer:",
                value: "Test user, 12345678900",
                extraIcon: "ic_m3_arrow_right_48pt_wght400"
            )
    )
    .environment(Container.shared.themeSettings())
}
