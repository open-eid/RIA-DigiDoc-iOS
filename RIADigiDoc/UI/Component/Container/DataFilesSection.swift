// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct DataFilesSection: View {
    @Environment(LanguageSettings.self) private var languageSettings

    @State private var viewModel: SigningViewModel
    let isContainerSigned: Bool
    let isNestedContainer: Bool
    @Binding var selectedDataFile: DataFileWrapper?
    @Binding var showSivaMessage: Bool
    @Binding var isFileSaved: Bool
    @Binding var showRemoveDataFileModal: Bool
    @Binding var navigateToNestedCryptoContainerView: Bool

    init(
        viewModel: SigningViewModel,
        isContainerSigned: Bool,
        isNestedContainer: Bool,
        selectedDataFile: Binding<DataFileWrapper?>,
        showSivaMessage: Binding<Bool>,
        isFileSaved: Binding<Bool>,
        showRemoveDataFileModal: Binding<Bool>,
        navigateToNestedCryptoContainerView: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self.isContainerSigned = isContainerSigned
        self.isNestedContainer = isNestedContainer
        self._selectedDataFile = selectedDataFile
        self._showSivaMessage = showSivaMessage
        self._isFileSaved = isFileSaved
        self._showRemoveDataFileModal = showRemoveDataFileModal
        self._navigateToNestedCryptoContainerView = navigateToNestedCryptoContainerView
    }

    var body: some View {
        DataFilesListView(
            dataFiles: viewModel.dataFiles,
            selectedDataFile: $selectedDataFile,
            showRemoveFileButton: !isContainerSigned && !isNestedContainer,
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

    private func openFile(_ dataFile: DataFileWrapper) {
        selectedDataFile = dataFile
        Task {
            if await viewModel.isSivaConfirmationNeeded(dataFile: dataFile) {
                showSivaMessage = true
            } else {
                await viewModel.handleFileOpening(dataFile: dataFile, isSivaConfirmed: true)
            }

            await MainActor.run {
                navigateToNestedCryptoContainerView = viewModel.navigateToNestedCryptoContainerView
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
    DataFilesSection(
        viewModel: Container.shared.signingViewModel(),
        isContainerSigned: false,
        isNestedContainer: false,
        selectedDataFile: .constant(nil),
        showSivaMessage: .constant(false),
        isFileSaved: .constant(false),
        showRemoveDataFileModal: .constant(false),
        navigateToNestedCryptoContainerView: .constant(false)
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
