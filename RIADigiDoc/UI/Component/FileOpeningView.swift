// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct FileOpeningView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dismiss) private var dismiss

    @Environment(LanguageSettings.self) private var languageSettings
    @State private var viewModel: FileOpeningViewModel

    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToSigningView: Bool
    @Binding var isNavigatingToEncryptView: Bool

    @State private var showSivaMessage = false

    private var isErrorShown: Bool {
        guard let errorMessage = viewModel.errorMessage else { return false }
        return !errorMessage.key.isEmpty
    }

    @State private var fileHandlingTask: Task<Void, Never>?

    init(
        isFileOpeningLoading: Binding<Bool>,
        isNavigatingToSigningView: Binding<Bool>,
        isNavigatingToEncryptView: Binding<Bool>
    ) {
        _viewModel = State(wrappedValue: Container.shared.fileOpeningViewModel())
        _isFileOpeningLoading = isFileOpeningLoading
        _isNavigatingToSigningView = isNavigatingToSigningView
        _isNavigatingToEncryptView = isNavigatingToEncryptView
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
                .sivaConfirmationAlert(
                    isPresented: $showSivaMessage,
                    onConfirm: { confirmed in
                        Task {
                            if confirmed {
                                await viewModel.handleSivaConfirmation()
                            } else {
                                await viewModel.handleSivaCancellation()
                            }
                            await handleFileOpening()
                        }
                    },
                    onReadMore: { dismiss() }
                )
        }
    }

    @MainActor
    private func startFileHandling() async {
        guard !Task.isCancelled else { return }

        await viewModel.handleFiles()

        if isErrorShown {
            await handleFileOpening()
            return
        }

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
            isNavigatingToSigningView = viewModel.isNavigatingToSigningView
            isNavigatingToEncryptView = viewModel.isNavigatingToEncryptView

            let isSivaConfirmed = viewModel.isSivaConfirmed
            let showFileAddedMessage = await viewModel.showFileAddedMessage()

            if isSivaConfirmed && showFileAddedMessage {
                let message = viewModel.addedFilesCount() > 1
                ? languageSettings.localized("Files successfully added")
                : languageSettings.localized("File successfully added")

                Toast.show(message, type: .success)

                if voiceOverEnabled {
                    AccessibilityUtil.announceMessage(message)
                }
            }
        } else {
            let localizedMessage = languageSettings.localized(
                errorMessage?.key ?? "General error",
                errorMessage?.args ?? []
            )
            Toast.show(localizedMessage)

            if voiceOverEnabled {
                AccessibilityUtil.announceMessage(localizedMessage)
            }

            viewModel.handleError()
            isFileOpeningLoading = viewModel.isFileOpeningLoading
            isNavigatingToSigningView = viewModel.isNavigatingToSigningView
            isNavigatingToEncryptView = viewModel.isNavigatingToEncryptView
        }
    }
}

#Preview {
    FileOpeningView(
        isFileOpeningLoading: .constant(true),
        isNavigatingToSigningView: .constant(false),
        isNavigatingToEncryptView: .constant(false),
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
