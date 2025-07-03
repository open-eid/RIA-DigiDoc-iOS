import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct FileOpeningView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @StateObject private var viewModel: FileOpeningViewModel

    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToNextView: Bool

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
                        Task {
                            await viewModel.handleFiles()
                            if viewModel.errorMessage == nil {
                                isFileOpeningLoading = viewModel.isFileOpeningLoading
                                isNavigatingToNextView = viewModel.isNavigatingToNextView
                                if await viewModel.showFileAddedMessage() {
                                    let message = viewModel.addedFilesCount() > 1
                                    ? languageSettings.localized("Files successfully added")
                                    : languageSettings.localized("File successfully added")

                                    Toast.show(message)
                                }
                            } else {
                                Toast.show(
                                    languageSettings.localized(viewModel.errorMessage?.message ?? "General error")
                                )
                                viewModel.handleError()
                                isFileOpeningLoading = viewModel.isFileOpeningLoading
                                isNavigatingToNextView = viewModel.isNavigatingToNextView
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    FileOpeningView(
        isFileOpeningLoading: .constant(true),
        isNavigatingToNextView: .constant(false)
    )
    .environmentObject(
        Container.shared.languageSettings())
}
