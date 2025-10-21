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
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: MobileIDSmartIDSettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.mobileIDSmartIDSettingsViewModel())
    }

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings relying party title")
        ) {
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default access title"),
                isSelected: viewModel.selectedOption == .defaultSetting,
                onSelect: {
                    viewModel.selectedOption = .defaultSetting
                }
            )
            OutlinedRadioButtonCard(
                title: languageSettings.localized("Main settings default manual access title"),
                isSelected: viewModel.selectedOption == .manualSetting,
                onSelect: {
                    viewModel.selectedOption = .manualSetting
                },
                content: {
                    FloatingLabelTextField(
                        title: languageSettings.localized("Main settings relying party title"),
                        text: $viewModel.relyingPartyUUID,
                        isSecure: true,
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
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
