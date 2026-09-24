// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct CryptoDataFilesSection: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var viewModel: EncryptViewModel
    let showOpenFileButton: Bool
    let showSaveFileButton: Bool
    let showRemoveFileButton: Bool
    let isNestedContainer: Bool
    @Binding var selectedDataFile: URL?
    @Binding var showSivaMessage: Bool
    @Binding var isFileSaved: Bool
    @Binding var showRemoveDataFileModal: Bool
    @Binding var navigateToNestedSignedContainerView: Bool

    init(
        viewModel: EncryptViewModel,
        showOpenFileButton: Bool,
        showSaveFileButton: Bool,
        showRemoveFileButton: Bool,
        isNestedContainer: Bool,
        selectedDataFile: Binding<URL?>,
        showSivaMessage: Binding<Bool>,
        isFileSaved: Binding<Bool>,
        showRemoveDataFileModal: Binding<Bool>,
        navigateToNestedSignedContainerView: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self.showOpenFileButton = showOpenFileButton
        self.showSaveFileButton = showSaveFileButton
        self.showRemoveFileButton = showRemoveFileButton
        self.isNestedContainer = isNestedContainer
        self._selectedDataFile = selectedDataFile
        self._showSivaMessage = showSivaMessage
        self._isFileSaved = isFileSaved
        self._showRemoveDataFileModal = showRemoveDataFileModal
        self._navigateToNestedSignedContainerView = navigateToNestedSignedContainerView
    }

    var body: some View {
        CryptoDataFilesListView(
            dataFiles: viewModel.dataFiles,
            selectedDataFile: $selectedDataFile,
            showOpenFileButton: showOpenFileButton,
            showSaveFileButton: showSaveFileButton,
            showRemoveFileButton: showRemoveFileButton,
            showRemoveDataFileModal: $showRemoveDataFileModal,
            onOpenFileButtonClick: openFile,
            onSaveDataFileButtonClick: saveFile,
            onRemoveFileButtonClick: { _ in
                showRemoveDataFileModal = true
            }
        )
        .sivaConfirmationAlert(isPresented: $showSivaMessage) { confirmed in
            confirmSiva(confirmed)
        }
        .background(fileSaverBackground)
        .filePreview(item: $viewModel.previewFile)
    }

    private func openFile(_ dataFile: URL) {
        selectedDataFile = dataFile
        Task {
            if await viewModel.isSivaConfirmationNeeded(dataFile: dataFile) {
                showSivaMessage = true
            } else {
                await viewModel.handleFileOpening(dataFile: dataFile, isSivaConfirmed: true)
            }

            await MainActor.run {
                navigateToNestedSignedContainerView = viewModel.navigateToNestedSignedContainerView
            }
        }
    }

    private func saveFile(_ dataFile: URL) {
        Task {
            await viewModel.handleSaveFile(dataFile: dataFile)
        }
    }

    @ViewBuilder private var fileSaverBackground: some View {
        FileSaverHandler(
            isPresented: $viewModel.isShowingFileSaver,
            fileURL: viewModel.selectedDataFile,
            languageSettings: languageSettings,
            onComplete: {
                if !isNestedContainer {
                    viewModel.removeSavedFilesDirectory()
                }
            },
            isFileSaved: $isFileSaved
        )
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

#Preview {
    CryptoDataFilesSection(
        viewModel: Container.shared.encryptViewModel(),
        showOpenFileButton: true,
        showSaveFileButton: true,
        showRemoveFileButton: true,
        isNestedContainer: false,
        selectedDataFile: .constant(nil),
        showSivaMessage: .constant(false),
        isFileSaved: .constant(false),
        showRemoveDataFileModal: .constant(false),
        navigateToNestedSignedContainerView: .constant(false)
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
