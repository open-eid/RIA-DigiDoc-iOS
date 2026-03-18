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

struct SaveButton: View {
    @AppTheme private var theme

    @Environment(LanguageSettings.self) private var languageSettings

    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image("ic_m3_download_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurfaceVariant)
                    .accessibilityLabel(languageSettings.localized("Save"))
            }
            .foregroundStyle(theme.onSurface)
            .padding(Dimensions.Padding.XXSPadding)
            .cornerRadius(Dimensions.Corner.MSCornerRadius)
        }
        .padding(.horizontal, Dimensions.Padding.MSPadding)
        .buttonStyle(.plain)
    }
}
