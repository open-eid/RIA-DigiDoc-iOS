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

import FactoryKit
import SwiftUI
import UtilsLib

struct DiagnosticsView: View {
    @AppTheme private var theme

    @Environment(LanguageSettings.self) private var languageSettings

    @Environment(\.dismiss) private var dismiss

    private let fileUtil: FileUtilProtocol

    @State private var enableOneTimeLogGeneration = false  // TODO: implement one time log generation logic

    @State private var tempDiagnosticsFileURL: URL?
    @State private var isShowingFileSaver = false
    @State private var isFileSaved: Bool = false

    @State private var viewModel: DiagnosticsViewModel

    init(
        fileUtil: FileUtilProtocol = Container.shared.fileUtil(),
    ) {
        _viewModel = State(wrappedValue: Container.shared.diagnosticsViewModel())
        self.fileUtil = fileUtil
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main diagnostics title"),
            onLeftClick: { dismiss() },
            content: {
                ScrollView {
                    VStack(
                        spacing: Dimensions.Padding.XXSPadding,
                        content: {
                            DiagnosticsHeaderButtons(
                                onCheckUpdateClick: {
                                    Task {
                                        let status = await viewModel.updateConfiguration()
                                        if !status {
                                            Toast.show(
                                                languageSettings.localized("No Internet connection")
                                            )
                                        }
                                    }
                                },
                                onSaveDiagnosticsClick: {
                                    Task {
                                        tempDiagnosticsFileURL = await viewModel.createLogFile(
                                            languageSettings: languageSettings
                                        )

                                        if fileUtil.fileExists(fileLocation: tempDiagnosticsFileURL) {
                                            isShowingFileSaver = true
                                        }
                                    }
                                }
                            )

                            ToggleSection(
                                isOn: $enableOneTimeLogGeneration,
                                label: languageSettings.localized("Main diagnostics logging switch")
                            )

                            DiagnosticsSections(
                                versionSectionContent: viewModel.versionSectionContent,
                                osSectionContent: viewModel.osSectionContent,
                                libdigidocVersion: viewModel.libdigidocVersion,
                                urlSectionContent: viewModel.urlSectionContent,
                                cdoc2SectionContent: viewModel.cdoc2SectionContent,
                                tslSectionContent: viewModel.tslSectionContent,
                                centralConfigurationSectionContent: viewModel.centralConfigurationSectionContent
                            )
                        }
                    )
                    .padding(Dimensions.Padding.SPadding)
                    .background(
                        FileSaverHandler(
                            isPresented: $isShowingFileSaver,
                            fileURL: tempDiagnosticsFileURL,
                            languageSettings: languageSettings,
                            onComplete: {
                                viewModel.removeLogFilesDirectory()
                            },
                            isFileSaved: $isFileSaved
                        )
                    )
                    .task {
                        await viewModel
                            .getConfigurationData(
                                configuration: viewModel.configuration
                            )
                    }
                    .onChange(of: viewModel.configuration, { _, newConfig in
                        if let newConfig {
                            Task { await viewModel.getConfigurationData(configuration: newConfig) }
                        }
                    })
                    .onDisappear {
                        Task {
                            await viewModel.removeObservers()
                        }
                    }
                }
            }
        )
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
}
