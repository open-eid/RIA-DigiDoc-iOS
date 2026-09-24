// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct LTASettingsView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var viewModel: LTASettingsViewModel

    init() {
        _viewModel = State(wrappedValue: Container.shared.ltaSettingsViewModel())
    }

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings lta tab title"),
            isScrollable: false
        ) {
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default lta disabled"),
                isSelected: !viewModel.isDefaultLTAEnabled,
                onSelect: {
                    viewModel.isDefaultLTAEnabled = false
                },
                accessibilityInputLabel: .disabledSetting
            )
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default lta title"),
                isSelected: viewModel.isDefaultLTAEnabled,
                onSelect: {
                    viewModel.isDefaultLTAEnabled = true
                },
                accessibilityInputLabel: .defaultSetting
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
    LTASettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
