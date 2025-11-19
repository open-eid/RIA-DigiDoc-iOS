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

    // MARK: - UI State
    @State private var showDialog = false
    @State private var dialogSelectedServerId: EncryptionServerOptionId = .defaultSetting

    // MARK: - Navigation
    @State private var navigateToCertificateView = false

    private let serverOptions: [EncryptionServerOption] = [
        EncryptionServerOption(id: .defaultSetting, titleKey: "Main settings crypto server option ria"),
        EncryptionServerOption(id: .manualSetting, titleKey: "Main settings crypto server option manual")
    ]
    private var selectedServerOption: EncryptionServerOption? {
        serverOptions.first { $0.id == viewModel.serverId }
    }

    @StateObject private var viewModel: EncryptionSettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.encryptionSettingsViewModel())
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
                            isSelected: viewModel.encryptionCdocOption == .cdoc1,
                            onSelect: {
                                viewModel.encryptionCdocOption = .cdoc1
                            }
                        )

                        OutlinedRadioButtonCard(
                            title: languageSettings.localized("Main settings crypto use cdoc2"),
                            isSelected: viewModel.encryptionCdocOption == .cdoc2,
                            onSelect: {
                                viewModel.encryptionCdocOption = .cdoc2
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

            if showDialog {
                chooseServerDialog
            }
        }
        .onDisappear {
            Task {
                await viewModel.saveSettings()
                await viewModel.removeObservers()
            }
        }
        .fileImporter(
            isPresented: $viewModel.isImportingCert,
            allowedContentTypes: [.x509Certificate],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task {
                    await viewModel.importCert(from: url)
                }
                viewModel.isImportingCert = false
            case .failure:
                viewModel.isImportingCert = false
            }
        }

        // MARK: - Navigation links
        if let certData = viewModel.certData {
            NavigationLink(
                destination: CertificateDetailView(
                    certificate: certData
                ),
                isActive: $navigateToCertificateView,
            ) { }
        }
    }

    @ViewBuilder
    private var manualCardContent: some View {
        ToggleSection(
            isOn: $viewModel.useKeyTransfer,
            label: languageSettings.localized("Main settings crypto use key transfer"),
            verticalPadding: Dimensions.Padding.XSPadding
        )
        if viewModel.useKeyTransfer {
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto server"),
                text: .constant(languageSettings.localized(selectedServerOption?.titleKey ?? "")),
                isDropdown: true,
                isDisabled: !viewModel.useKeyTransfer,
                onDropdownTap: {
                    dialogSelectedServerId = viewModel.serverId
                    showDialog = true
                }
            )
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto uuid"),
                text: $viewModel.serverInfo.uuid,
                isDisabled: !viewModel.useKeyTransfer || viewModel.serverId == .defaultSetting
            )
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto fetch url"),
                text: $viewModel.serverInfo.fetchURL,
                isDisabled: !viewModel.useKeyTransfer || viewModel.serverId == .defaultSetting
            )
            FloatingLabelTextField(
                title: languageSettings.localized("Main settings crypto post url"),
                text: $viewModel.serverInfo.postURL,
                isDisabled: !viewModel.useKeyTransfer || viewModel.serverId == .defaultSetting
            )
            if viewModel.serverId == .manualSetting {
                AdvancedSettingsCertificateSection(
                    certificateInfoHeader: languageSettings.localized("Main settings crypto certificate title"),
                    showCertificateInfo: viewModel.certData != nil,
                    certificateIssuedTo: viewModel.getCertIssuer(),
                    certificateValidTo: viewModel.getCertNotValidAfter(
                        expiredLabel: languageSettings.localized("Main settings cert expired")
                    ),
                    onShowCertificatePressed: {
                        navigateToCertificateView = true
                    },
                    onAddCertificatePressed: {
                        viewModel.isImportingCert = true
                    }
                )
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
                    trailingSpacer: false
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
                        dialogSelectedServerId = viewModel.serverId
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
                        viewModel.serverId = dialogSelectedServerId
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
