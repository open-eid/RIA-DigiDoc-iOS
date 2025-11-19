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

struct ValidationSettingsView: View {
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings
    @Environment(\.dismiss) private var dismiss

    // MARK: - Navigation
    @State private var navigateToCertificateView = false

    @StateObject private var viewModel: ValidationSettingsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.validationSettingsViewModel())
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main settings validation services title"),
            onLeftClick: {
                dismiss()
            },
            excludeDestinations: [.advanced],
            content: {
                VStack(spacing: Dimensions.Padding.ZeroPadding) {
                    AdvancedSettingsSectionColumn(
                        title: languageSettings.localized("Main settings siva service title")
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
                                if !viewModel.isLoading {
                                    AdvancedSettingsManualCardContent(
                                        textFieldTitle: languageSettings.localized("Main settings siva service url"),
                                        textFieldText: $viewModel.validationServiceUrl,
                                        certificateInfoHeader:
                                            languageSettings.localized("Main settings siva certificate title"),
                                        showCertificateInfo: viewModel.sivaCertData != nil,
                                        certificateIssuedTo: viewModel.getSiVaCertIssuer(),
                                        certificateValidTo: viewModel.getSiVaCertNotValidAfter(
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
                        )
                    }

                    Spacer()
                }
                .padding(.horizontal, Dimensions.Padding.SPadding)
            }
        )
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
                    await viewModel.importSiVaCert(from: url)
                }
                viewModel.isImportingCert = false
            case .failure:
                viewModel.isImportingCert = false
            }
        }

        // MARK: - Navigation links
        if let sivaCertData = viewModel.sivaCertData {
            NavigationLink(
                destination: CertificateDetailView(
                    certificate: sivaCertData
                ),
                isActive: $navigateToCertificateView,
            ) { }
        }
    }
}

// MARK: - Preview

#Preview {
    ValidationSettingsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
