// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct CryptoFileOpeningView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.dismiss) private var dismiss

    @Environment(LanguageSettings.self) private var languageSettings
    @State private var viewModel: CryptoFileOpeningViewModel

    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToNextView: Bool

    @State private var fileHandlingTask: Task<Void, Never>?

    init(
        isFileOpeningLoading: Binding<Bool>,
        isNavigatingToNextView: Binding<Bool>
    ) {
        _viewModel = State(wrappedValue: Container.shared.cryptoFileOpeningViewModel())
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
        }
    }

    @MainActor
    private func startFileHandling() async {
        guard !Task.isCancelled else { return }

        await viewModel.handleFiles()
        await viewModel.handleConfirmation()
        await handleFileOpening()
    }

    @MainActor
    private func handleFileOpening() async {
        let errorMessage = viewModel.errorMessage
        if errorMessage == nil {
            isFileOpeningLoading = viewModel.isFileOpeningLoading
            isNavigatingToNextView = viewModel.isNavigatingToNextView

            let showFileAddedMessage = await viewModel.showFileAddedMessage()

            if showFileAddedMessage {
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
            isNavigatingToNextView = viewModel.isNavigatingToNextView
        }
    }
}

#Preview {
    FileOpeningView(
        isFileOpeningLoading: .constant(true),
        isNavigatingToSigningView: .constant(false),
        isNavigatingToEncryptView: .constant(false)
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
    .environment(NavigationPathManager())
}
