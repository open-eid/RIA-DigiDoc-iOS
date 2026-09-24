// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
