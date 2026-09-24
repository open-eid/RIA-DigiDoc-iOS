// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct AdvancedSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
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
                            action: onRestoreDefaultSettingsClick,
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

    private func onRestoreDefaultSettingsClick() {
        Task {
            await viewModel.restoreDefaultSettings()
            let message =
                languageSettings.localized("Main settings use default settings message")
            if voiceOverEnabled {
                var saveButtonAccessibilityAnnouncement = AttributedString(message)
                saveButtonAccessibilityAnnouncement.accessibilitySpeechAnnouncementPriority = .high
                AccessibilityNotification.Announcement(saveButtonAccessibilityAnnouncement).post()
            }
            Toast.show(message, type: .success)
        }
    }
}

// MARK: - Preview
#Preview {
    AdvancedSettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
