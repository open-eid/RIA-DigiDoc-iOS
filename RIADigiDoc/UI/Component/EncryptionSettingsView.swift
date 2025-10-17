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

struct EncryptionSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    // TODO: Most of these will move into the viewModel
    @State private var useKeyServer = false
    @State private var showDialog = false
    @State private var selectedServerId: EncryptionServerOptionId = .defaultSetting
    @State private var encryptionCdocOption: EncryptionCdocOption = .cdoc1
    @State private var dialogSelectedServerId: EncryptionServerOptionId = .defaultSetting

    private let serverOptions: [EncryptionServerOption] = [
        EncryptionServerOption(id: .defaultSetting, titleKey: "Main settings crypto server option ria"),
        EncryptionServerOption(id: .manualSetting, titleKey: "Main settings crypto server option manual")
    ]
    private var selectedServerOption: EncryptionServerOption? {
        serverOptions.first { $0.id == selectedServerId }
    }

    var body: some View {
        ZStack {
            TopBarContainer(
                title: languageSettings.localized("Main settings crypto services title"),
                onLeftClick: { dismiss() },
                excludeDestinations: [.advanced],
                content: {
                    ScrollView {
                        OutlinedRadioButtonCard(
                            title: languageSettings.localized("Main settings crypto use cdoc1"),
                            isSelected: encryptionCdocOption == .cdoc1,
                            onSelect: {
                                encryptionCdocOption = .cdoc1
                            }
                        )

                        OutlinedRadioButtonCard(
                            title: languageSettings.localized("Main settings crypto use cdoc2"),
                            isSelected: encryptionCdocOption == .cdoc2,
                            onSelect: {
                                encryptionCdocOption = .cdoc2
                            },
                            contentSpacing: Dimensions.Padding.MPadding,
                            content: {
                                manualCardContent
                            }
                        )
                        Spacer()
                    }
                    .padding(.horizontal, Dimensions.Padding.SPadding)
                    .padding(.vertical, Dimensions.Padding.SPadding)
                }
            )
            .background(theme.surface)

            if showDialog {
                chooseServerDialog
            }
        }
    }

    @ViewBuilder
    private var manualCardContent: some View {
        ToggleSection(
            isOn: $useKeyServer,
            label: languageSettings.localized("Main settings crypto use key transfer"),
            verticalPadding: Dimensions.Padding.XSPadding
        )
        if useKeyServer {
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto server"),
                text: .constant(languageSettings.localized(selectedServerOption?.titleKey ?? "")),
                isDropdown: true,
                isDisabled: !useKeyServer,
                onDropdownTap: {
                    showDialog = true
                }
            )
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto uuid"),
                text: .constant("abc"),
                isDisabled: !useKeyServer || selectedServerId == .defaultSetting
            )
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto fetch url"),
                text: .constant("abc"),
                isDisabled: !useKeyServer || selectedServerId == .defaultSetting
            )
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto post url"),
                text: .constant("abc"),
                isDisabled: !useKeyServer || selectedServerId == .defaultSetting
            )
            if selectedServerId == .manualSetting {
                AdvancedSettingsCertificateSection(
                    certificateInfoHeader: languageSettings.localized("Main settings crypto certificate title"),
                    showCertificateInfo: false,
                    certificateIssuedTo: "certificateIssuedTo",
                    certificateValidTo: "certificateValidTo",
                    onShowCertificatePressed: {},
                    onAddCertificatePressed: {})
            }
        }
    }

    @ViewBuilder
    private var chooseServerDialog: some View {
        Color.black
            .opacity(Dimensions.Shadow.LOpacity)
            .ignoresSafeArea()

        VStack(
            alignment: .leading,
            spacing: Dimensions.Padding.MPadding,
            content: {
                Text(languageSettings.localized("Main settings crypto choose server option"))
                    .foregroundStyle(theme.onSurface)
                    .font(typography.headlineSmall)

                RadioButtonChooserView<EncryptionServerOption>(
                    options: serverOptions,
                    isSelected: { serverOption in
                        serverOption.id == dialogSelectedServerId
                    },
                    titleKey: { serverOption in serverOption.titleKey },
                    onSelect: { serverOption in
                        dialogSelectedServerId = serverOption.id
                    },
                    accessibilityLabel: { serverOption, isSelected in
                        let title = languageSettings.localized(serverOption.titleKey)
                        let selected = isSelected
                        ? languageSettings.localized("Radiobutton selected")
                        : languageSettings.localized("Radiobutton unselected")
                        return "\(title) \(selected)"
                    },
                    trailingSpacer: false,
                    backgroundColor: theme.surfaceContainerHighest
                )

                dialogButtonRow
            }
        )
        .padding(Dimensions.Padding.MPadding)
        .background(RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
            .fill(theme.surfaceContainerHighest)
        )
        .padding(.horizontal, Dimensions.Padding.XLPadding)
    }

    @ViewBuilder
    private var dialogButtonRow: some View {
        HStack(
            content: {
                Spacer()

                Button(
                    action: {
                        dialogSelectedServerId = selectedServerId
                        showDialog = false
                    },
                    label: {
                        Text(languageSettings.localized("Close"))
                            .font(typography.labelLarge)
                            .foregroundStyle(theme.primary)
                            .padding(.horizontal, Dimensions.Padding.MSPadding)
                    }
                )
                .buttonStyle(.plain)

                Button(
                    action: {
                        selectedServerId = dialogSelectedServerId
                        showDialog = false
                    },
                    label: {
                        Text(languageSettings.localized("Choose button"))
                            .font(typography.labelLarge)
                            .foregroundStyle(theme.primary)
                            .padding(.horizontal, Dimensions.Padding.MSPadding)
                    }
                )
                .buttonStyle(.plain)
            }
        )
    }
}

// MARK: - Preview

#Preview {
    EncryptionSettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
