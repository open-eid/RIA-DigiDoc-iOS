import FactoryKit
import SwiftUI

struct LanguageChooserView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @StateObject private var viewModel: LanguageChooserViewModel

    @State private var showSettingsBottomSheetFromButton = false
    @State private var navigateToThemeChooser = false
    @State private var navigateToAdvancedSettings = false

    init(
        viewModel: LanguageChooserViewModel = Container.shared.languageChooserViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var settingsBottomSheetActions: [BottomSheetButton] {
        SettingsMenuBottomSheetActions.actions(
            currentPage: .language,
            onThemeChooserClick: {
                navigateToThemeChooser = true
            },
            onAdvancedSettingsClick: {
                navigateToAdvancedSettings = true
            }
        )
    }

    private let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(code: "et", titleKey: "Init lang locale et"),
        SupportedLanguage(code: "en", titleKey: "Init lang locale en")
    ]

    var body: some View {
        RadioButtonChooserView<SupportedLanguage>(
            title: languageSettings.localized("Main settings menu language"),
            options: supportedLanguages,
            isSelected: { languageOption in
                languageOption.code == viewModel.selectedLanguage
            },
            titleKey: { languageOption in languageOption.titleKey },
            onSelect: { languageOption in
                Task {await viewModel.selectLanguage(code: languageOption.code)}
            },
            accessibilityLabel: { languageOption, isSelected in
                let title = languageSettings.localized(languageOption.titleKey)
                let selected = isSelected
                ? languageSettings.localized("Menu language selected")
                : languageSettings.localized("Menu language")
                return "\(title) \(selected)"
            },
            onRightSecondaryClick: {
                showSettingsBottomSheetFromButton = true
            }
        )
        .bottomSheet(isPresented: $showSettingsBottomSheetFromButton, actions: settingsBottomSheetActions)

        NavigationLink(
            destination: ThemeChooserView(),
            isActive: $navigateToThemeChooser
        ) { }
        NavigationLink(
            destination: AdvancedSettingsView(),
            isActive: $navigateToAdvancedSettings
        ) { }
    }
}

// MARK: - Preview
#Preview {
    LanguageChooserView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
