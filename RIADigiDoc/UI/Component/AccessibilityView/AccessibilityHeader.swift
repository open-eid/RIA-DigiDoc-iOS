import SwiftUI
import FactoryKit

struct AccessibilityHeader: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

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
        .environmentObject(
            Container.shared.languageSettings()
        )
}
