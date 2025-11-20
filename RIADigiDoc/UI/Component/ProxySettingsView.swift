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

struct ProxySettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: ProxySettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.proxySettingsViewModel())
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings proxy title"),
            onLeftClick: { dismiss() },
            excludeDestinations: [.advanced],
            content: {
                ScrollView {
                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy no proxy"),
                        isSelected: viewModel.proxyInfo.option == .disabled,
                        onSelect: {
                            viewModel.proxyInfo.option = .disabled
                        }
                    )

                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy use system"),
                        isSelected: viewModel.proxyInfo.option == .system,
                        onSelect: {
                            viewModel.proxyInfo.option = .system
                        }
                    )

                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy manual"),
                        isSelected: viewModel.proxyInfo.option == .manual,
                        onSelect: {
                            viewModel.proxyInfo.option = .manual
                        },
                        contentSpacing: Dimensions.Padding.MPadding,
                        content: {
                            manualCardContent
                        }
                    )

                    Button(
                        action: {
                            Task {
                                let isConnected = await viewModel.checkInternetAccess()
                                let message = isConnected
                                ? languageSettings.localized("Main settings proxy check connection success")
                                : languageSettings.localized("Main settings proxy check connection unsuccessful")
                                Toast.show(message)
                            }
                        },
                        label: {
                            Text(languageSettings.localized("Main settings proxy check connection"))
                                .font(typography.labelLarge)
                                .foregroundStyle(theme.primary)
                        }
                    )
                    .padding(.vertical, Dimensions.Padding.LPadding)

                    Spacer()
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
                .padding(.vertical, Dimensions.Padding.SPadding)
            }
        )
        .background(theme.surface)
        .onDisappear {
            Task {
                await viewModel.saveSettings()
            }
        }
        .onChange(of: viewModel.portText) { _ in
            if viewModel.isPortTextValid {
                guard let port = Int(viewModel.portText) else { return }
                viewModel.proxyInfo.port = port
            }
        }
    }

    @ViewBuilder
    private var manualCardContent: some View {
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy host"),
            text: $viewModel.proxyInfo.host,
        )
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy port"),
            text: $viewModel.portText,
            isError: !viewModel.isPortTextValid,
            errorText: languageSettings.localized("Main settings proxy port error"),
            keyboardType: .numberPad
        )
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy username"),
            text: $viewModel.proxyInfo.username,
        )
        FloatingLabelTextField(
            title: languageSettings.localized("Main settings proxy password"),
            text: $viewModel.proxyInfo.password,
            isSecure: true
        )
    }
}

// MARK: - Preview

#Preview {
    ProxySettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
