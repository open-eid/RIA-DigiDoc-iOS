// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
                    .lineLimit(nil)
                    .minimumScaleFactor(0.5)
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
