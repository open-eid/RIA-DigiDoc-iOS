import FactoryKit
import SwiftUI

struct ThemeChooserView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @EnvironmentObject private var themeSettings: ThemeSettings

    private let supportedThemes: [SupportedTheme] = [
        SupportedTheme(themeKey: Theme.system, titleKey: "Main settings theme system"),
        SupportedTheme(themeKey: Theme.light, titleKey: "Main settings theme light"),
        SupportedTheme(themeKey: Theme.dark, titleKey: "Main settings theme dark")
    ]

    var body: some View {
        RadioButtonChooserView<SupportedTheme>(
            title: languageSettings.localized("Main settings menu appearance"),
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
}

// MARK: - Preview
#Preview {
    ThemeChooserView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
