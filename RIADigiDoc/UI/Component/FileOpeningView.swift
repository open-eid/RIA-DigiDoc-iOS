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

struct FileOpeningView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @Environment(LanguageSettings.self) private var languageSettings
    @State private var viewModel: FileOpeningViewModel

    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToNextView: Bool

    @State private var showSivaMessage = false

    private var sivaMessage: String {
        languageSettings.localized("Siva message")
    }

    private var sivaMessageUrl: String {
        languageSettings.localized("Siva message url")
    }

    @State private var fileHandlingTask: Task<Void, Never>?

    init(
        isFileOpeningLoading: Binding<Bool>,
        isNavigatingToNextView: Binding<Bool>
    ) {
        _viewModel = State(wrappedValue: Container.shared.fileOpeningViewModel())
        _isFileOpeningLoading = isFileOpeningLoading
        _isNavigatingToNextView = isNavigatingToNextView
    }

    var body: some View {
        VStack {
            LoadingView()
                .onAppear {
                    fileHandlingTask = Task { await startFileHandling() }
                }
                .onDisappear {
                    fileHandlingTask?.cancel()
                }
                .alert(sivaMessage, isPresented: $showSivaMessage) {
                    Button(languageSettings.localized("OK")) {
                        Task {
                            await viewModel.handleSivaConfirmation()
                            await handleFileOpening()
                        }
                    }
                    Button(languageSettings.localized("Cancel")) {
                        Task {
                            await viewModel.handleSivaCancellation()
                            await handleFileOpening()
                        }
                    }
                    Button(languageSettings.localized("Read more here")) {
                        if let url = URL(string: sivaMessageUrl),
                           UIApplication.shared.canOpenURL(url) {
                            openURL(url)
                        }
                        dismiss()
                    }
                }
        }
    }

    @MainActor
    private func startFileHandling() async {
        guard !Task.isCancelled else { return }

        await viewModel.handleFiles()

        if await viewModel.isSivaConfirmationNeeded() {
            showSivaMessage = true
        } else {
            await viewModel.handleSivaConfirmation()
            await handleFileOpening()
        }
    }

    @MainActor
    private func handleFileOpening() async {
        let errorMessage = viewModel.errorMessage
        if errorMessage == nil {
            isFileOpeningLoading = viewModel.isFileOpeningLoading
            isNavigatingToNextView = viewModel.isNavigatingToNextView

            let isSivaConfirmed = viewModel.isSivaConfirmed
            let showFileAddedMessage = await viewModel.showFileAddedMessage()

            if isSivaConfirmed && showFileAddedMessage {
                let message = viewModel.addedFilesCount() > 1
                ? languageSettings.localized("Files successfully added")
                : languageSettings.localized("File successfully added")

                Toast.show(message)
            }
        } else {
            Toast.show(languageSettings.localized(errorMessage?.key ?? "General error", errorMessage?.args ?? []))
            viewModel.handleError()
            isFileOpeningLoading = viewModel.isFileOpeningLoading
            isNavigatingToNextView = viewModel.isNavigatingToNextView
        }
    }
}

#Preview {
    FileOpeningView(
        isFileOpeningLoading: .constant(true),
        isNavigatingToNextView: .constant(false)
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
