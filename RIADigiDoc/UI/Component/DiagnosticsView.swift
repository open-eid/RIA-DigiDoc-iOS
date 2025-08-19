import FactoryKit
import SwiftUI
import UtilsLib

struct DiagnosticsView: View {
    @AppTheme private var theme

    @EnvironmentObject private var languageSettings: LanguageSettings

    @Environment(\.dismiss) private var dismiss

    private let fileUtil: FileUtilProtocol

    @State private var enableOneTimeLogGeneration = false  // TODO: implement one time log generation logic

    @State private var tempDiagnosticsFileURL: URL?
    @State private var isShowingFileSaver = false
    @State private var isFileSaved: Bool = false

    @StateObject private var viewModel: DiagnosticsViewModel

    init(
        viewModel: DiagnosticsViewModel = Container.shared.diagnosticsViewModel(),
        fileUtil: FileUtilProtocol = Container.shared.fileUtil(),
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.fileUtil = fileUtil
    }

    var body: some View {
        TopBarContainer(
            title: languageSettings.localized("Main diagnostics title"),
            onLeftClick: {
                dismiss()
            },
            content: {
                ScrollView {
                    VStack(
                        spacing: Dimensions.Padding.XXSPadding,
                        content: {
                            DiagnosticsHeaderButtons(
                                onCheckUpdateClick: {
                                    Task { await viewModel.updateConfiguration() }
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

                            OneTimeLogGenerationToggleSection(
                                enableOneTimeLogGeneration: $enableOneTimeLogGeneration)

                            DiagnosticsSections()
                                .environmentObject(viewModel)
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
                }
            }
        )
        .background(theme.surface)
    }
}

// MARK: - Preview
#Preview {
    DiagnosticsView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
