// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct NFCActionView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    var leftIcon: String
    var rightIcon: String

    @Binding var message: String

    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Image(leftIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(theme.onSurfaceVariant)
                    .frame(width: Dimensions.Icon.IconSizeXXL, height: Dimensions.Icon.IconSizeXXL)
                    .accessibilityHidden(true)

                Image(rightIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(theme.onSurfaceVariant)
                    .frame(width: Dimensions.Icon.IconSizeXXL, height: Dimensions.Icon.IconSizeXXL)
                    .accessibilityHidden(true)
            }
            .padding(.top, Dimensions.Padding.SPadding)
            .padding(.vertical, Dimensions.Padding.LPadding)

            Text(verbatim: languageSettings.localized(message))
                .font(typography.headlineSmall)
                .foregroundStyle(theme.onSurfaceVariant)
                .padding(.horizontal, Dimensions.Padding.LPadding)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    NFCActionView(
        leftIcon: "ic_m3_phonelink_ring_48pt_wght400",
        rightIcon: "ic_m3_id_card_48pt_wght400",
        message: .constant("Hold your phone near the ID-card")
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
