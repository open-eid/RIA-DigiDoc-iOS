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
