/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import FactoryKit
import SwiftUI

struct LanguageChooserView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings
    @StateObject private var viewModel: LanguageChooserViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.languageChooserViewModel())
    }

    private let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(code: "et", titleKey: "Init lang locale et", accessibilityInputLabel: "Estonian"),
        SupportedLanguage(code: "en", titleKey: "Init lang locale en", accessibilityInputLabel: "English")
    ]

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings menu language"),
            onLeftClick: {
                dismiss()
            },
            excludeDestinations: [.language],
            content: {
                RadioButtonChooserView<SupportedLanguage>(
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
                    accessibilityInputLabel: { languageOption in
                        languageOption.accessibilityInputLabel
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
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
