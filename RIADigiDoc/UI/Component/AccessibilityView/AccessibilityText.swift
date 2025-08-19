import SwiftUI
import FactoryKit

struct AccessibilityText: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @EnvironmentObject private var languageSettings: LanguageSettings

    let text: String
    var isUrl: Bool = false
    var bottomPadding: CGFloat = Dimensions.Padding.SPadding
    var isTitle: Bool = false

    var body: some View {
        if isUrl {
            if let url = URL(string: text) {
                Link(destination: url) {
                    Text(text)
                        .underline(true, color: theme.primary)
                        .foregroundStyle(theme.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, bottomPadding)
                }
                .accessibilityLabel(Text(verbatim: "\(languageSettings.localized("Open Button")) \(text)"))
            }
        } else {
            Text(text)
                .font(isTitle ? typography.titleLarge : typography.bodyLarge)
                .foregroundStyle(theme.onSurface)
                .multilineTextAlignment(.leading)
                .padding(.bottom, bottomPadding)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(
        content: {
            AccessibilityText(
                text: "I am a title",
                isTitle: true
            )
            AccessibilityText(text: "I am text")
            AccessibilityText(
                text: "I am a link",
                isUrl: true
            )
        }
    ).environmentObject(
        Container.shared.languageSettings()
    )
}
