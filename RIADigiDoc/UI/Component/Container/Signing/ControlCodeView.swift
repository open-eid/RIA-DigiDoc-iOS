/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

struct ControlCodeView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @AppTheme private var theme
    @AppTypography private var typography

    var icon: String

    @Binding var controlCode: String
    @Binding var infoMessage: String

    @AccessibilityFocusState private var isControlCodeFocused: Bool

    private var isControlCodeValid: Bool {
        !controlCode.isEmpty && controlCode.allSatisfy { $0.isNumber }
    }

    var body: some View {
        VStack(alignment: .center) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .foregroundStyle(theme.onSurfaceVariant)
                .frame(width: Dimensions.Icon.IconSizeXXL, height: Dimensions.Icon.IconSizeXXL)
                .padding(.vertical, Dimensions.Padding.LPadding)
                .padding(.top, Dimensions.Padding.SPadding)
                .accessibilityHidden(true)

            VStack(alignment: .center, spacing: Dimensions.Padding.SPadding) {
                Text(verbatim: languageSettings.localized("Control code"))
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .accessibilityHidden(!isControlCodeValid)

                Text(verbatim: controlCode)
                    .speechSpellsOutCharacters(true)
                    .font(typography.displayMedium)
                    .foregroundStyle(theme.onSurface)
                    .scaleEffect(x: Dimensions.Scaling.WideScaling, y: Dimensions.Scaling.DefaultScaling)
                    .accessibilityIdentifier("controlCode")
                    .accessibilityHidden(!isControlCodeValid)

                Text(verbatim: languageSettings.localized(infoMessage))
                    .font(typography.bodyLarge)
                    .foregroundStyle(theme.onSurface)
                    .accessibilityIdentifier("infoMessage")
            }
            .onChange(of: controlCode) { _, newValue in
                if (!newValue.isEmpty && newValue.allSatisfy { $0.isNumber }) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isControlCodeFocused = true
                    }
                }
            }
            .accessibilityFocused($isControlCodeFocused)
            .accessibilityElement(children: .combine)
        }
        .onDisappear {
            controlCode = "- - - -"
            infoMessage = ""
        }
    }
}

#Preview {
    ControlCodeView(
        icon: "mobile_id_logo",
        controlCode: .constant("1234"),
        infoMessage: .constant("Mobile-ID info message")
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
