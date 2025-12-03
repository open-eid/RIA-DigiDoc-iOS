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
import LibdigidocLibSwift

struct CryptoDataFilesSection: View {
    @Environment(\.openURL) private var openURL
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

    init(
        viewModel: EncryptViewModel,
        showOpenFileButton: Bool,
        showSaveFileButton: Bool,
        showRemoveFileButton: Bool,
        isNestedContainer: Bool,
        selectedDataFile: Binding<URL?>,
        showSivaMessage: Binding<Bool>,
        isFileSaved: Binding<Bool>,
        showRemoveDataFileModal: Binding<Bool>
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
    }

    private var sivaMessage: String {
        languageSettings.localized("Siva message")
    }

    private var sivaMessageUrl: String {
        languageSettings.localized("Siva message url")
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
        .background(fileSaverBackground)
        .quickLookPreview($viewModel.previewFile)
    }

    private func openFile(_ dataFile: URL) {
        selectedDataFile = dataFile
        Task {
            if await viewModel.isSivaConfirmationNeeded(dataFile: dataFile) {
                showSivaMessage = true
            } else {
                await viewModel.handleFileOpening(dataFile: dataFile, isSivaConfirmed: true)
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
