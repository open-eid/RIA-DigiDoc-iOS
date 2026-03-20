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

struct ProxySettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ProxySettingsViewModel

    private var proxyHostTitle: String {
        languageSettings.localized("Main settings proxy host")
    }

    private var proxyPortTitle: String {
        languageSettings.localized("Main settings proxy port")
    }

    private var proxyUsernameTitle: String {
        languageSettings.localized("Main settings proxy username")
    }

    private var proxyPasswordTitle: String {
        languageSettings.localized("Main settings proxy password")
    }

    init() {
        _viewModel = State(wrappedValue: Container.shared.proxySettingsViewModel())
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
                        },
                        accessibilityInputLabel: .disabledSetting
                    )

                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy use system"),
                        isSelected: viewModel.proxyInfo.option == .system,
                        onSelect: {
                            viewModel.proxyInfo.option = .system
                        },
                        accessibilityInputLabel: .systemSetting
                    )

                    OutlinedRadioButtonCard(
                        title: languageSettings.localized("Main settings proxy manual"),
                        isSelected: viewModel.proxyInfo.option == .manual,
                        onSelect: {
                            viewModel.proxyInfo.option = .manual
                        },
                        contentSpacing: Dimensions.Padding.MPadding,
                        accessibilityInputLabel: .manualSetting,
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
                                Toast.show(message, type: isConnected ? .success : .error)

                                if voiceOverEnabled {
                                    var saveButtonAccessibilityAnnouncement = AttributedString(message)
                                    saveButtonAccessibilityAnnouncement.accessibilitySpeechAnnouncementPriority = .high
                                    AccessibilityNotification.Announcement(saveButtonAccessibilityAnnouncement).post()
                                }
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
        .onDisappear {
            Task {
                await viewModel.saveSettings()
            }
        }
        .onChange(of: viewModel.portText) {
            if viewModel.isPortTextValid {
                guard let port = Int(viewModel.portText) else { return }
                viewModel.proxyInfo.port = port
            }
        }
    }

    @ViewBuilder
    private var manualCardContent: some View {
        FloatingLabelTextField(
            title: proxyHostTitle,
            placeholder: proxyHostTitle,
            text: $viewModel.proxyInfo.host,
            identifier: "proxyHost"
        )
        FloatingLabelTextField(
            title: proxyPortTitle,
            placeholder: proxyPortTitle,
            text: $viewModel.portText,
            isError: !viewModel.isPortTextValid,
            errorText: languageSettings.localized("Main settings proxy port error"),
            keyboardType: .numberPad,
            identifier: "proxyPort"
        )
        FloatingLabelTextField(
            title: proxyUsernameTitle,
            placeholder: proxyUsernameTitle,
            text: $viewModel.proxyInfo.username,
            identifier: "proxyUsername"
        )
        FloatingLabelTextField(
            title: proxyPasswordTitle,
            placeholder: proxyPasswordTitle,
            text: $viewModel.proxyInfo.password,
            isSecure: true,
            identifier: "proxyPassword"
        )
    }
}

// MARK: - Preview

#Preview {
    ProxySettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
