import FactoryKit
import SwiftUI

struct LanguageChooserView: View {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    @State private var selectedLanguage: String = "et"

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
                        LanguageOptionRow(
                            title: languageSettings.localized("Init lang locale et"),
                            isSelected: selectedLanguage == "et",
                            onTap: {
                                selectedLanguage = "et"
                            }
                        )

                        Divider()

                        LanguageOptionRow(
                            title: languageSettings.localized("Init lang locale en"),
                            isSelected: selectedLanguage == "en",
                            onTap: {
                                selectedLanguage = "en"
                            }
                        )

                        Divider()

                        Spacer()
                    }
                )
            }
        )
        .background(theme.surface)
        .onAppear {
            selectedLanguage = languageSettings.currentLanguage
        }
    }
}

// MARK: - Preview
#Preview {
    LanguageChooserView()
        .environmentObject(Container.shared.languageSettings())
}
