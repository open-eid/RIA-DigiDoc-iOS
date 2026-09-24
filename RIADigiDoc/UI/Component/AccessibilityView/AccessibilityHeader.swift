// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct AccessibilityHeader: View {
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(
            alignment: .leading,
            content: {
                AccessibilityText(
                    text: languageSettings.localized("Main accessibility introduction"),
                )

                AccessibilityText(
                    text: languageSettings.localized("Main accessibility more info"),
                    bottomPadding: Dimensions.Padding.ZeroPadding
                )
                AccessibilityText(
                    text: languageSettings.localized("Main accessibility more info url"),
                    isUrl: true
                )

                AccessibilityText(
                    text: languageSettings.localized("Main accessibility introduction 2"))
            }

        )
    }
}

// MARK: - Preview
#Preview {
    AccessibilityHeader()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())

}
