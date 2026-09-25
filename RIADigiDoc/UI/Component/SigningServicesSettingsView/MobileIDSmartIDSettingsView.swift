// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CommonsLib
import SwiftUI
import FactoryKit

struct MobileIDSmartIDSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var viewModel: MobileIDSmartIDSettingsViewModel

    private var relyingPartyTitle: String {
        languageSettings.localized("Main settings relying party title")
    }

    init() {
        _viewModel = State(wrappedValue: Container.shared.mobileIDSmartIDSettingsViewModel())
    }

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings relying party title"),
            isScrollable: false
        ) {
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default access title"),
                isSelected: viewModel.selectedOption == .defaultSetting,
                onSelect: {
                    viewModel.selectedOption = .defaultSetting
                },
                accessibilityInputLabel: .defaultSetting
            )
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default manual access title"),
                isSelected: viewModel.selectedOption == .manualSetting,
                onSelect: {
                    viewModel.selectedOption = .manualSetting
                },
                accessibilityInputLabel: .manualSetting,
                content: {
                    FloatingLabelTextField(
                        title: relyingPartyTitle,
                        placeholder: relyingPartyTitle,
                        text: $viewModel.relyingPartyUUID,
                        isSecure: true,
                        identifier: "relyingPartyUUID"
                    )
                }
            )
            Spacer()
        }
        .onDisappear {
            Task {
                await viewModel.saveSettings()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MobileIDSmartIDSettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
