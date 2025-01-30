import SwiftUI
import LibdigidocLibSwift

struct FileOpeningView: View {
    @EnvironmentObject var languageSettings: LanguageSettings
    @StateObject private var viewModel: FileOpeningViewModel

    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToNextView: Bool

    init(
        viewModel: FileOpeningViewModel = AppAssembler.shared.resolve(FileOpeningViewModel.self),
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
                            }
                        }
                    }
            }.alert(item: $viewModel.errorMessage) { errorMessage in
                Alert(
                    title: Text(languageSettings.localized("Error")),
                    message: Text(languageSettings.localized(errorMessage.message ?? "General error")),
                    dismissButton: .default(Text("OK")) {
                        viewModel.handleError()
                        isFileOpeningLoading = viewModel.isFileOpeningLoading
                        isNavigatingToNextView = viewModel.isNavigatingToNextView
                    }
                )
            }
        }
    }
}

#Preview {
    FileOpeningView(isFileOpeningLoading: .constant(true), isNavigatingToNextView: .constant(false))
}
