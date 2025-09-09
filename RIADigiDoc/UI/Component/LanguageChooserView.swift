import FactoryKit
import SwiftUI

struct LanguageChooserView: View {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

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
        TopBarContainer(
            title: languageSettings.localized("Main settings menu language"),
            onLeftClick: {
                dismiss()
            },
            content: {
                VStack(
                    spacing: Dimensions.Padding.ZeroPadding,
                    content: {
                        ForEach(supportedLanguages, id: \.code) { language in
                            LanguageOptionRow(
                                title: languageSettings.localized(language.titleKey),
                                isSelected: viewModel.selectedLanguage == language.code,
                                onTap: { viewModel.selectLanguage(code: language.code) }
                            )
                            Divider()
                        }

                        Spacer()
                    }
                )
            }
        )
        .background(theme.surface)
    }
}

// MARK: - Supporting Types

private struct SupportedLanguage {
    let code: String
    let titleKey: String
}

// MARK: - Preview
#Preview {
    LanguageChooserView()
        .environmentObject(Container.shared.languageSettings())
}
