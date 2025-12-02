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
