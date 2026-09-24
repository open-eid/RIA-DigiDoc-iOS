// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
