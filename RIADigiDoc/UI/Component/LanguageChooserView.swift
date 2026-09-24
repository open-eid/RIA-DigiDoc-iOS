// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import SwiftUI

struct LanguageChooserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageSettings.self) private var languageSettings
    @State private var viewModel: LanguageChooserViewModel

    init() {
        _viewModel = State(wrappedValue: Container.shared.languageChooserViewModel())
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings menu language"),
            onLeftClick: {
                dismiss()
            },
            excludeDestinations: [.language],
            content: {
                RadioButtonChooserView<SupportedLanguage>(
                    options: languageSettings.supportedLanguages,
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
                        : languageSettings.localized("Menu language unselected")
                        return "\(title) \(selected)"
                    },
                    accessibilityInputLabel: { languageOption in
                        let inputLabel = languageOption.accessibilityInputLabel
                        let title = languageSettings.localized(languageOption.titleKey)
                        if inputLabel == title { return nil }
                        return inputLabel
                    }
                )
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.XSPadding)
            }
        )
    }
}

// MARK: - Preview
#Preview {
    LanguageChooserView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
