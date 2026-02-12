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

struct IdCardActionView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AccessibilityFocusState private var isIdCardActionMessageFocused: Bool

    @AppTheme private var theme
    @AppTypography private var typography

    var icon: String

    @Binding var message: String

    var body: some View {
        VStack(alignment: .center) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(theme.onBackground)
                .frame(
                    width: Dimensions.Icon.IconSizeXXL,
                    height: Dimensions.Icon.IconSizeXXL
                )
                .accessibilityHidden(true)

            Text(verbatim: languageSettings.localized(message))
                .font(typography.headlineSmall)
                .foregroundStyle(theme.onSurfaceVariant)
                .padding(.horizontal, Dimensions.Padding.LPadding)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityFocused($isIdCardActionMessageFocused)
                .accessibilityAddTraits([.updatesFrequently])
                .onChange(of: message) { _, newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        AccessibilityUtil.announceMessage(newValue)
                    }
                }
        }
        .padding(.vertical, Dimensions.Padding.LPadding)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isIdCardActionMessageFocused = true
            }
        }
    }
}

#Preview {
    IdCardActionView(
        icon: "ic_m3_smart_card_reader_48pt_wght400",
        message: .constant("ID card connect card reader")
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
