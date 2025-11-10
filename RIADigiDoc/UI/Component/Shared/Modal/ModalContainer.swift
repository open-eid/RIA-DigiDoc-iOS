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

struct ModalContainer<Content: View>: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    var icon: String?
    var title: String
    var confirmButtonTitle: String = "OK"
    var onConfirm: () -> Void
    var onCancel: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Dimensions.Padding.MPadding) {
            HStack(alignment: .center) {
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onSurface)
                        .accessibilityHidden(true)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Text(verbatim: title)
                .foregroundStyle(theme.onSurface)
                .font(typography.headlineSmall)
                .padding(.leading, Dimensions.Padding.MSPadding)
                .padding(.trailing, Dimensions.Padding.LPadding)

            content
                .padding(.horizontal, Dimensions.Padding.SPadding)

            HStack(spacing: Dimensions.Padding.MPadding) {
                Button(languageSettings.localized("Cancel")) { onCancel() }
                    .font(typography.labelLarge)
                    .foregroundStyle(theme.primary)

                Button(languageSettings.localized(confirmButtonTitle)) { onConfirm() }
                    .font(typography.labelLarge)
                    .foregroundStyle(theme.primary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, Dimensions.Padding.MSPadding)
            .padding(.horizontal, Dimensions.Padding.SPadding)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
                .fill(theme.surfaceContainerHighest)
        )
        .padding(.horizontal, Dimensions.Padding.XLPadding)
    }
}
