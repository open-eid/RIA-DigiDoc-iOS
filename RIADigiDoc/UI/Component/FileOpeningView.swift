import SwiftUI
import LibdigidoclibSwift

struct FileOpeningView: View {
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
                    title: Text("Error"),
                    message: Text(errorMessage.message ?? "Unknown error"),
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
