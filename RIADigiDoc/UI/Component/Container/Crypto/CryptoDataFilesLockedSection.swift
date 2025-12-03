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
import LibdigidocLibSwift

struct CryptoDataFilesLockedSection: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography
    
    var body: some View {
        VStack {
            HStack {
                Image("ic_m3_encrypted_48pt_wght400")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                    .foregroundStyle(theme.onSurface)
                    .padding(.trailing, Dimensions.Padding.SPadding)
                    .accessibilityHidden(true)

                Text(verbatim: languageSettings.localized("Crypto files encrypted"))
                    .font(typography.bodyMedium)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(4)
                    .truncationMode(.middle)
                    .multilineTextAlignment(TextAlignment.leading)
                    .accessibilityLabel(
                        Text(
                            verbatim: languageSettings.localized("Crypto files encrypted").lowercased()
                        )
                    )

                Spacer()
            }
            .padding(Dimensions.Padding.MSPadding)
        }
        .listRowInsets(EdgeInsets())
        .accessibilityAddTraits([.isButton])
    }
}
