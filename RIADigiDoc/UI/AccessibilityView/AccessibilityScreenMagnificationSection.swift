import SwiftUI
import FactoryKit

struct AccessibilityScreenMagnificationSection: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

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
        .environmentObject(
            Container.shared.languageSettings()
        )
}
