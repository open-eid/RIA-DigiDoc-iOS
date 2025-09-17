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

    init(
        viewModel: FileOpeningViewModel = Container.shared.fileOpeningViewModel(),
        isFileOpeningLoading: Binding<Bool>,
        isNavigatingToNextView: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isFileOpeningLoading = isFileOpeningLoading
        _isNavigatingToNextView = isNavigatingToNextView
    }

    var body: some View {
        NavigationView {
            VStack {
                LoadingView()
                    .onAppear {
                        Task { await startFileHandling() }
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
        if viewModel.errorMessage == nil {
            isFileOpeningLoading = viewModel.isFileOpeningLoading
            isNavigatingToNextView = viewModel.isNavigatingToNextView

            let shouldShowFileAddedMessage = await viewModel.showFileAddedMessage()

            let isSivaConfirmed = viewModel.isSivaConfirmed

            if isSivaConfirmed && shouldShowFileAddedMessage {
                let message = viewModel.addedFilesCount() > 1
                ? languageSettings.localized("Files successfully added")
                : languageSettings.localized("File successfully added")

                Toast.show(message)
            }
        } else {
            Toast.show(languageSettings.localized(viewModel.errorMessage?.message ?? "General error"))
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
