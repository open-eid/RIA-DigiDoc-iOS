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
                    .foregroundStyle(theme.onBackground)
                    .frame(width: Dimensions.Icon.IconSizeXXL, height: Dimensions.Icon.IconSizeXXL)
                    .accessibilityHidden(true)

                Image(rightIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(theme.onBackground)
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
