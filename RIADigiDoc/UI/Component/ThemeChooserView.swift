import FactoryKit
import SwiftUI

struct SupportedTheme: Identifiable, Equatable, Hashable {
    let themeKey: Theme
    let titleKey: String
    var id: Theme { themeKey }
}

struct ThemeChooserView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

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
                themeOption.themeKey == Theme.currentSetting()
            },
            titleKey: { themeOption in themeOption.titleKey },
            onSelect: { themeOption in Theme.set(themeOption.themeKey) },
            accessibilityLabel: { themeOption, isSelected in
                isSelected
                ? "\(languageSettings.localized(themeOption.titleKey)) "
                + "\(languageSettings.localized("Menu theme selected"))"
                : "\(languageSettings.localized(themeOption.titleKey)) "
                + "\(languageSettings.localized("Menu theme"))"
            }
        )
    }
}

// MARK: - Preview
#Preview {
    ThemeChooserView()
        .environmentObject(Container.shared.languageSettings())
}
