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

import SwiftUI
import FactoryKit

struct AdvancedSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings

    @Environment(\.dismiss) private var dismiss

    @Environment(NavigationPathManager.self) private var pathManager

    @State private var checkedAskRoleAndAddress = false

    @State private var viewModel: AdvancedSettingsViewModel

    init() {
        _viewModel = State(wrappedValue: Container.shared.advancedSettingsViewModel())
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings menu advanced"),
            onLeftClick: {
                dismiss()
            },
            excludeDestinations: [.advanced],
            content: {
                ScrollView {
                    VStack(spacing: Dimensions.Padding.ZeroPadding) {
                        AdvancedSettingsSectionColumn(
                            title: languageSettings.localized("Main settings general title"),
                            isScrollable: false
                        ) {
                            AdvancedSettingsCheckboxRow(
                                label: languageSettings.localized("Main settings ask role and address title"),
                                isChecked: $checkedAskRoleAndAddress
                            )
                            .onAppear {
                                Task {
                                    let isRoleAndAddressEnabled = await viewModel.getIsRoleAndAddressEnabled()

                                    await MainActor.run {
                                        checkedAskRoleAndAddress = isRoleAndAddressEnabled
                                    }
                                }
                            }
                            .onChange(of: checkedAskRoleAndAddress) { _, newValue in
                                Task {
                                    await viewModel.setIsRoleAndAddressEnabled(newValue)
                                }
                            }
                        }

                        Divider().padding(.vertical, Dimensions.Padding.SPadding)

                        AdvancedSettingsSectionColumn(
                            title: languageSettings.localized("Main settings system settings title"),
                            isScrollable: false
                        ) {
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings signing services title"),
                                onClick: {
                                    pathManager.navigate(to: .signingServicesSettingsView)
                                }
                            )
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings validation services title"),
                                onClick: {
                                    pathManager.navigate(to: .validationSettingsView)
                                }
                            )
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings crypto services title"),
                                onClick: {
                                    pathManager.navigate(to: .encryptionSettingsView)
                                }
                            )
                            AdvancedSettingsLinkRow(
                                label: languageSettings.localized("Main settings proxy title"),
                                onClick: {
                                    pathManager.navigate(to: .proxySettingsView)
                                }
                            )
                        }

                        Button(
                            action: {
                                Task {
                                    await viewModel.restoreDefaultSettings()
                                    Toast.show(
                                        languageSettings.localized("Main settings use default settings message")
                                    )
                                }
                            },
                            label: {
                                Text(languageSettings.localized("Main settings use default settings button title"))
                                    .font(typography.labelLarge)
                                    .foregroundStyle(theme.primary)
                            }
                        )
                        .padding(.vertical, Dimensions.Padding.LPadding)

                        Spacer()
                    }
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                }
            }
        )
    }
}

// MARK: - Preview
#Preview {
    AdvancedSettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
