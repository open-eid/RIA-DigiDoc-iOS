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
        if #available(iOS 16.0, *) {
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
                        }

                        Spacer()

                        if let extraIcon = signatureDataItem.extraIcon {
                            Image(extraIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                .foregroundStyle(theme.onBackground)
                                .accessibilityHidden(true)
                        }
                    }
                }
                .contentShape(Rectangle())
                .padding(.vertical, Dimensions.Padding.XSPadding)
                .accessibilityElement(children: .combine)

                Divider()
            }
        } else {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: Dimensions.Padding.XXSPadding) {
                        Text(verbatim: signatureDataItem.title)
                            .font(typography.labelSmall)
                            .foregroundStyle(theme.onSurfaceVariant)
                        Text(verbatim: signatureDataItem.value)
                            .foregroundStyle(theme.onSurface)
                            .font(typography.bodyLarge)
                    }

                    Spacer()

                    if let extraIcon = signatureDataItem.extraIcon {
                        Image(extraIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onBackground)
                            .accessibilityHidden(true)
                    }
                }
                .padding(.vertical, Dimensions.Padding.XSPadding)
            }

            Divider()
        }
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
    .environmentObject(Container.shared.themeSettings())
}
