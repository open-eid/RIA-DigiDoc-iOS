import SwiftUI
import FactoryKit

struct AccessibilityScreenReaderSection: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    var body: some View {
        VStack(
            alignment: .leading,
            content: {
                AccessibilityText(
                    text: languageSettings.localized("Main accessibility introduction screen reader title"),
                    isTitle: true
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen reader introduction"
                    )
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen reader introduction 2"
                    )
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen reader introduction apps"
                    )
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen reader introduction ios"
                    ),
                    bottomPadding: Dimensions.Padding.ZeroPadding
                )
                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen reader introduction ios url"
                    ),
                    isUrl: true
                )

                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen reader introduction android"
                    ),
                    bottomPadding: Dimensions.Padding.ZeroPadding
                )
                AccessibilityText(
                    text: languageSettings.localized(
                        "Main accessibility introduction screen reader introduction android url"
                    ),
                    isUrl: true
                )
            }
        )
    }
}

// MARK: - Preview
#Preview {
    AccessibilityScreenReaderSection()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
