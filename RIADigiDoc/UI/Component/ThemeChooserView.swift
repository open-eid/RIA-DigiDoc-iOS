import FactoryKit
import SwiftUI

struct ThemeChooserView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings
    @EnvironmentObject private var themeSettings: ThemeSettings

    private let supportedThemes: [SupportedTheme] = [
        SupportedTheme(themeKey: .system, titleKey: "Main settings theme system"),
        SupportedTheme(themeKey: .light, titleKey: "Main settings theme light"),
        SupportedTheme(themeKey: .dark, titleKey: "Main settings theme dark")
    ]

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings menu appearance"),
            onLeftClick: {
                dismiss()
            },
            excludeDestinations: [.theme],
            content: {
                RadioButtonChooserView<SupportedTheme>(
                    options: supportedThemes,
                    isSelected: { themeOption in
                        themeOption.themeKey == themeSettings.getSelectedTheme()
                    },
                    titleKey: { themeOption in themeOption.titleKey },
                    onSelect: { themeOption in
                        Task {await themeSettings.setSelectedTheme(themeOption.themeKey)}
                    },
                    accessibilityLabel: { themeOption, isSelected in
                        let title = languageSettings.localized(themeOption.titleKey)
                        let selected = isSelected
                        ? languageSettings.localized("Menu theme selected")
                        : languageSettings.localized("Menu theme")
                        return "\(title) \(selected)"
                    }
                )
            }
        )
    }
}

// MARK: - Preview
#Preview {
    ThemeChooserView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
