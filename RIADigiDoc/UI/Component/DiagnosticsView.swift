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
    @AppTypography private var typography

    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) var openURL

    private let fileUtil: FileUtilProtocol

    private enum ExportType {
        case diagnosticsFile
        case logFile
    }

    @State private var activeExportType: ExportType?
    @State private var tempFileURL: URL?
    @State private var isShowingFileSaver: Bool = false
    @State private var isFileSaved: Bool = false

    @State private var viewModel: DiagnosticsViewModel

    private var restartText: String {
        if viewModel.enableOneTimeLogGeneration {
            return languageSettings.localized("Main diagnostics restart message")
        } else {
            return languageSettings.localized("Main diagnostics restart message deactivate")
        }
    }

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
                                onCheckUpdateClick: onCheckUpdateClick,
                                onSaveDiagnosticsClick: {
                                    Task {
                                        tempFileURL = await viewModel.createDiagnosticsFile(
                                            languageSettings: languageSettings
                                        )
                                        triggerFileSaver(type: .diagnosticsFile)
                                    }
                                }
                            )

                            ToggleSection(
                                isOn: $viewModel.enableOneTimeLogGeneration,
                                label: languageSettings.localized("Main diagnostics logging switch")
                            )

                            if viewModel.showSaveLogButton {
                                PrimaryOutlinedButton(
                                    text: languageSettings.localized("Main diagnostics save log"),
                                    assetImageName: "ic_m3_download_48pt_wght400",
                                    action: {
                                        Task {
                                            tempFileURL = await viewModel.createLogFile()
                                            triggerFileSaver(type: .logFile)
                                        }
                                    }
                                )
                            }

                            if viewModel.showRestartText {
                                HStack {
                                    Text(restartText)
                                        .font(typography.bodyLarge)
                                        .foregroundStyle(theme.error)
                                        .padding(.top, Dimensions.Padding.ZeroPadding)
                                        .padding(.bottom, Dimensions.Padding.MSPadding)
                                    Spacer()
                                }
                            }

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
                            fileURL: tempFileURL,
                            languageSettings: languageSettings,
                            onComplete: {
                                Task {
                                    await handleFileSaverCompletion()
                                }
                            },
                            isFileSaved: $isFileSaved
                        )
                    )
                    .alert(
                        languageSettings.localized("Main diagnostics restart message"),
                        isPresented: $viewModel.showRestartActivateAlert
                    ) {alertContent}
                    .alert(
                        languageSettings.localized("Main diagnostics restart message deactivate"),
                        isPresented: $viewModel.showRestartDeactivateAlert
                    ) {alertContent}
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
                    .onChange(of: viewModel.enableOneTimeLogGeneration) { _, newValue in
                        Task {
                            await viewModel.onEnableOneTimeLogGenerationChange(newValue)
                        }
                    }
                    .onDisappear {
                        Task {
                            await viewModel.removeObservers()
                        }
                    }
                }
            }
        )
    }

    private func onCheckUpdateClick() {
        Task {
            let isUpdated = await viewModel.updateConfiguration()

            let messageKey = isUpdated ?
            "Configuration update successful" :
            "Configuration update unsuccessful"

            let updateMessage = languageSettings.localized(messageKey)

            Toast.show(updateMessage)

            if voiceOverEnabled {
                var saveButtonAccessibilityAnnouncement = AttributedString(updateMessage)
                saveButtonAccessibilityAnnouncement.accessibilitySpeechAnnouncementPriority = .high
                AccessibilityNotification.Announcement(saveButtonAccessibilityAnnouncement).post()
            }
        }
    }

    @ViewBuilder
    private var alertContent: some View {
        Button(languageSettings.localized("OK")) {}
        Button(languageSettings.localized("Read more here")) {
            if let url = URL(
                string: languageSettings.localized("main diagnostics restart message url")
            ) {
                openURL(url)
            }
        }
    }

    private func triggerFileSaver(type: ExportType) {
        self.activeExportType = type
        if fileUtil.fileExists(fileLocation: tempFileURL) {
            isShowingFileSaver = true
        }
    }

    private func handleFileSaverCompletion() async {
        guard let type = activeExportType else { return }

        switch type {
        case .diagnosticsFile:
            viewModel.onDiagnosticsFileSavingComplete()
        case .logFile:
            await viewModel.onLogFileSavingComplete()
        }

        activeExportType = nil
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
