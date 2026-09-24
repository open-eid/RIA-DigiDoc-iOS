// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct TimeStampSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @Environment(LanguageSettings.self) private var languageSettings

    @Environment(NavigationPathManager.self) private var pathManager

    @State private var viewModel: TimeStampSettingsViewModel

    init() {
        _viewModel = State(wrappedValue: Container.shared.timeStampSettingsViewModel())
    }

    var body: some View {
        AdvancedSettingsSectionColumn(
            title: languageSettings.localized("Main settings tsa url title"),
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
                    if !viewModel.isLoading {
                        AdvancedSettingsManualCardContent(
                            textFieldTitle: languageSettings.localized("Main settings tsa url title"),
                            textFieldText: $viewModel.tsaUrl,
                            certificateInfoHeader:
                                languageSettings.localized("Main settings timestamp cert title"),
                            showCertificateInfo: viewModel.tsaCertData != nil,
                            certificateIssuedTo: viewModel.getTSACertIssuer(),
                            certificateValidTo: viewModel.getTSACertNotValidAfter(
                                expiredLabel: languageSettings.localized("Main settings cert expired")
                            ),
                            onShowCertificatePressed: {
                                if let tsaCertData = viewModel.tsaCertData {
                                    pathManager.navigate(to: .certificateDetailView(certificate: tsaCertData))
                                }
                            },
                            onAddCertificatePressed: {
                                viewModel.isImportingTSACert = true
                            },
                            identifier: "tsaUrl"
                        )
                    }
                }
            )

            Spacer()
        }
        .onDisappear {
            Task {
                await viewModel.saveSettings()
            }
        }
        .fileImporter(
            isPresented: $viewModel.isImportingTSACert,
            allowedContentTypes: [.x509Certificate],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task {
                    await viewModel.importTSACert(from: url)
                }
                viewModel.isImportingTSACert = false
            case .failure:
                viewModel.isImportingTSACert = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TimeStampSettingsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
