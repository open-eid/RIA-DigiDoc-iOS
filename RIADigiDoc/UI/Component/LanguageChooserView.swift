import FactoryKit
import SwiftUI

struct SupportedLanguage: Identifiable, Equatable, Hashable {
    let code: String
    let titleKey: String
    var id: String { code }
}

struct LanguageChooserView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @StateObject private var viewModel: LanguageChooserViewModel

    init(
        viewModel: LanguageChooserViewModel = Container.shared.languageChooserViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
            onSelect: { languageOption in viewModel.selectLanguage(code: languageOption.code) },
            accessibilityLabel: { languageOption, isSelected in
                isSelected
                ? "\(languageSettings.localized(languageOption.titleKey)) "
                + "\(languageSettings.localized("Menu language selected"))"
                : "\(languageSettings.localized("Menu language")) "
                + "\(languageSettings.localized(languageOption.titleKey))"
            }
        )
    }
}

// MARK: - Preview
#Preview {
    LanguageChooserView()
        .environmentObject(Container.shared.languageSettings())
}
