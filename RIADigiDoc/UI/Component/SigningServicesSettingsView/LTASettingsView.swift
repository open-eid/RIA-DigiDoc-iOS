/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
