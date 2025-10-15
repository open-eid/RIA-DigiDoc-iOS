import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct FileOpeningView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var languageSettings: LanguageSettings
    @StateObject private var viewModel: FileOpeningViewModel

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
        _viewModel = StateObject(wrappedValue: Container.shared.fileOpeningViewModel())
        _isFileOpeningLoading = isFileOpeningLoading
        _isNavigatingToNextView = isNavigatingToNextView
    }

    var body: some View {
        NavigationView {
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
    .environmentObject(Container.shared.languageSettings())
    .environmentObject(Container.shared.themeSettings())
}
