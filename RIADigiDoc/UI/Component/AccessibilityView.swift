import SwiftUI
import FactoryKit

struct AccessibilityView: View {
    @AppTheme private var theme

    @EnvironmentObject private var languageSettings: LanguageSettings

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main home menu accessibility"),
            onLeftClick: {
                dismiss()
            },
            content: {
                ScrollView {
                    VStack(
                        spacing: Dimensions.Padding.MPadding,
                        content: {
                            AccessibilityHeader()
                            AccessibilityScreenReaderSection()
                            AccessibilityScreenMagnificationSection()
                        }
                    ).padding(.horizontal, Dimensions.Padding.SPadding)
                }
            }
        )
        .background(theme.surface)
    }
}

// MARK: - Preview
#Preview {
    AccessibilityView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
