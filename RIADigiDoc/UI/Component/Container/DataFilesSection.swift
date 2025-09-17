import SwiftUI
import LibdigidocLibSwift

struct DataFilesSection: View {
    @Environment(\.openURL) private var openURL

    @ObservedObject var viewModel: SigningViewModel
    let isContainerSigned: Bool
    let isNestedContainer: Bool
    @Binding var selectedDataFile: DataFileWrapper?
    @Binding var showSivaMessage: Bool
    @Binding var isFileSaved: Bool
    let languageSettings: LanguageSettings

    private var sivaMessage: String {
        languageSettings.localized("Siva message")
    }

    private var sivaMessageUrl: String {
        languageSettings.localized("Siva message url")
    }

    var body: some View {
        DataFilesListView(
            dataFiles: viewModel.dataFiles,
            showRemoveFileButton: !isContainerSigned && !isNestedContainer,
            onOpenFileButtonClick: openFile,
            onSaveDataFileButtonClick: saveFile
        )
        .alert(sivaMessage, isPresented: $showSivaMessage, actions: alertActions)
        .background(fileSaverBackground)
        .quickLookPreview($viewModel.previewFile)
    }

    private func openFile(_ dataFile: DataFileWrapper) {
        selectedDataFile = dataFile
        Task {
            if await viewModel.isSivaConfirmationNeeded(dataFile: dataFile) {
                showSivaMessage = true
            } else {
                await viewModel.handleFileOpening(dataFile: dataFile, isSivaConfirmed: true)
            }
        }
    }

    private func saveFile(_ dataFile: DataFileWrapper) {
        Task {
            await viewModel.handleSaveFile(dataFile: dataFile)
        }
    }

    @ViewBuilder private var fileSaverBackground: some View {
        FileSaverHandler(
            isPresented: $viewModel.isShowingFileSaver,
            fileURL: viewModel.selectedDataFile,
            languageSettings: languageSettings,
            onComplete: { viewModel.removeSavedFilesDirectory() },
            isFileSaved: $isFileSaved
        )
    }

    @ViewBuilder private func alertActions() -> some View {
        Button(languageSettings.localized("OK")) {
            confirmSiva(true)
        }
        Button(languageSettings.localized("Cancel")) {
            confirmSiva(false)
        }
        Button(languageSettings.localized("Read more here")) {
            if let url = URL(string: sivaMessageUrl),
               UIApplication.shared.canOpenURL(url) {
                openURL(url)
            }
            showSivaMessage = false
        }
    }

    private func confirmSiva(_ confirmed: Bool) {
        guard let dataFile = selectedDataFile else {
            showSivaMessage = false
            return
        }
        Task {
            await viewModel.handleFileOpening(dataFile: dataFile, isSivaConfirmed: confirmed)
        }
    }
}
