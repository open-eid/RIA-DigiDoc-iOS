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

import CommonsLib
import SwiftUI
import FactoryKit

struct EncryptionSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @AppTheme private var theme
    @AppTypography private var typography

    @AccessibilityFocusState private var isDialogHeaderFocused: Bool

    // MARK: - UI State
    @State private var showDialog = false
    @State private var dialogSelectedServerId: String = Constants.CryptoDefaultValues.encryptionServerInfoUUID

    private var selectedServerOption: EncryptionServerOption? {
        viewModel.getServerOptions().first { $0.id == viewModel.serverId }
    }

    @State private var viewModel: EncryptionSettingsViewModel

    private var cryptoServerTitle: String {
        languageSettings.localized("Main settings crypto server")
    }

    private var cryptoUuidTitle: String {
        languageSettings.localized("Main settings crypto uuid")
    }

    private var cryptoFetchUrlTitle: String {
        languageSettings.localized("Main settings crypto fetch url")
    }

    private var cryptoPostUrlTitle: String {
        languageSettings.localized("Main settings crypto post url")
    }

    init() {
        _viewModel = State(wrappedValue: Container.shared.encryptionSettingsViewModel())
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
                            },
                            accessibilityInputLabel: .defaultSetting
                        )

                        OutlinedRadioButtonCard(
                            title: languageSettings.localized("Main settings crypto use cdoc2"),
                            isSelected: viewModel.encryptionCdocOption == .cdoc2,
                            onSelect: {
                                viewModel.encryptionCdocOption = .cdoc2
                            },
                            contentSpacing: Dimensions.Padding.MPadding,
                            accessibilityInputLabel: .manualSetting,
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
            .accessibilityHidden(showDialog)

            if showDialog {
                chooseServerDialog
            }
        }
        .onDisappear {
            Task {
                await viewModel.saveSettings()
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
            case .failure(let error):
                viewModel.isImportingCert = false
                viewModel.handleFileImportFailure(error)
                showFileImportFailureMessage()
            }
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
                title: cryptoServerTitle,
                placeholder: cryptoServerTitle,
                text: .constant(languageSettings.localized(selectedServerOption?.titleKey ?? "")),
                isDropdown: true,
                isDisabled: !viewModel.useKeyTransfer,
                onDropdownTap: {
                    dialogSelectedServerId = viewModel.serverId
                    showDialog = true
                    isDialogHeaderFocused = true
                },
                identifier: "cryptoServer"
            )

            FloatingLabelTextField(
                title: cryptoUuidTitle,
                placeholder: cryptoUuidTitle,
                text: $viewModel.serverInfo.uuid,
                isDisabled: !viewModel.useKeyTransfer
                    || viewModel.serverId != viewModel.cdoc2ManualKeyTransferServerUUID,
                identifier: "cryptoUuid"
            )
            FloatingLabelTextField(
                title: cryptoFetchUrlTitle,
                placeholder: cryptoFetchUrlTitle,
                text: $viewModel.serverInfo.fetchURL,
                isDisabled: !viewModel.useKeyTransfer
                    || viewModel.serverId != viewModel.cdoc2ManualKeyTransferServerUUID,
                identifier: "cryptoFetchUrl"
            )
            FloatingLabelTextField(
                title: cryptoPostUrlTitle,
                placeholder: cryptoPostUrlTitle,
                text: $viewModel.serverInfo.postURL,
                isDisabled: !viewModel.useKeyTransfer
                    || viewModel.serverId != viewModel.cdoc2ManualKeyTransferServerUUID,
                identifier: "cryptoPostUrl"
            )
            if viewModel.serverId == viewModel.cdoc2ManualKeyTransferServerUUID {
                AdvancedSettingsCertificateSection(
                    certificateInfoHeader: languageSettings.localized("Main settings crypto certificate title"),
                    showCertificateInfo: viewModel.certData != nil,
                    certificateIssuedTo: viewModel.getCertIssuer(),
                    certificateValidTo: viewModel.getCertNotValidAfter(
                        expiredLabel: languageSettings.localized("Main settings cert expired")
                    ),
                    onShowCertificatePressed: {
                        if let certData = viewModel.certData {
                            pathManager.navigate(to: .certificateDetailView(certificate: certData))
                        }
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

            ViewThatFits(in: .vertical) {
                dialogContent

                ScrollView {
                    dialogContent
                }
            }
            .padding(Dimensions.Padding.MPadding)
            .background(RoundedRectangle(cornerRadius: Dimensions.Corner.MCornerRadius)
                .fill(theme.surfaceContainerHighest)
            )
            .padding(.horizontal, Dimensions.Padding.XLPadding)
            .padding(.vertical, Dimensions.Padding.XLPadding)
        }

        @ViewBuilder
        private var dialogContent: some View {
            VStack(
                alignment: .leading,
                spacing: Dimensions.Padding.MPadding,
                content: {
                    Text(languageSettings.localized("Main settings crypto choose server option"))
                        .foregroundStyle(theme.onSurface)
                        .font(typography.headlineSmall)
                        .accessibilityHeading(.h1)
                        .accessibilityAddTraits([.isHeader])
                        .accessibilityFocused($isDialogHeaderFocused)

                    RadioButtonChooserView<EncryptionServerOption>(
                        options: viewModel.getServerOptions(),
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
                        accessibilityInputLabel: {serverOption in serverOption.accessibilityInputLabel},
                        trailingSpacer: false
                    )

                    dialogButtonRow
                }
            )
        }

        @ViewBuilder
        private var dialogButtonRow: some View {
        ViewThatFits {
            HStack(
                content: {
                    Spacer()
                    closeDialogButton.fixedSize()
                    chooseDialogButton.fixedSize()
                }
            )

            VStack(
                alignment: .trailing,
                spacing: Dimensions.Padding.MPadding,
                content: {
                    chooseDialogButton
                    closeDialogButton
                }
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    private var closeDialogButton: some View {
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
    }

    @ViewBuilder
    private var chooseDialogButton: some View {
        Button(
            action: {
                viewModel.serverId = dialogSelectedServerId
                Task {
                    await viewModel.refreshServerInfo()
                }

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

    private func showFileImportFailureMessage() {
        let message = languageSettings.localized("Could not load selected files")
        Toast.show(message)
        AccessibilityUtil.announceMessage(message)
    }
}

// MARK: - Preview

#Preview {
    EncryptionSettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
