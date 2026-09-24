// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct AccessibilityScreenMagnificationSection: View {
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(
            alignment: .leading,
            content: {
                AccessibilityText(
                    text: languageSettings.localized("Main accessibility introduction screen magnification title"),
                    isTitle: true
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification introduction"
                    )
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification screen tools"
                    )
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification screen tools ios"
                    ),
                    bottomPadding: Dimensions.Padding.ZeroPadding
                )
                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification screen tools ios url"
                    ),
                    isUrl: true
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification screen tools android"
                    ),
                    bottomPadding: Dimensions.Padding.ZeroPadding
                )
                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification screen tools android url"
                    ),
                    isUrl: true
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification tools"
                    )
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification tools ios"
                    ),
                    bottomPadding: Dimensions.Padding.ZeroPadding
                )
                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification tools ios url"
                    ),
                    isUrl: true
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification tools android"
                    ),
                    bottomPadding: Dimensions.Padding.ZeroPadding
                )
                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen magnification tools android url"
                    ),
                    isUrl: true
                )
            }
        )
    }
}

// MARK: - Preview
#Preview {
    AccessibilityScreenMagnificationSection()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
