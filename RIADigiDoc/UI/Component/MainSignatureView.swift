import SwiftUI
import LibdigidocLibSwift

struct MainSignatureView: View {

    @EnvironmentObject var languageSettings: LanguageSettings

    @StateObject private var viewModel: MainSignatureViewModel

    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var isNavigatingToRecentDocumentsView = false

    @Binding private var externalFiles: [URL]

    init(
        viewModel: MainSignatureViewModel = AppAssembler.shared.resolve(MainSignatureViewModel.self),
        externalFiles: Binding<[URL]>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self._externalFiles = externalFiles
    }

    var body: some View {
        VStack {
            Button(languageSettings.localized("Choose file")) {
                viewModel.isImporting = true
            }
            .fileImporter(
                isPresented: $viewModel.isImporting,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                isFileOpeningLoading = true
                viewModel.isImporting = false
                self.viewModel.setChosenFiles(result)
            }
            .fullScreenCover(isPresented: $isFileOpeningLoading) {
                FileOpeningView(
                    isFileOpeningLoading: $isFileOpeningLoading,
                    isNavigatingToNextView: $isNavigatingToSigningView
                )
            }

            NavigationLink(
                destination: SigningView(),
                isActive: $isNavigatingToSigningView
            ) {}

            Button(languageSettings.localized("Recent documents")) {
                isNavigatingToRecentDocumentsView = true
            }

            NavigationLink(
                destination: RecentDocumentsView(),
                isActive: $isNavigatingToRecentDocumentsView
            ) {}
        }
        .onChange(of: externalFiles) { extFiles in
            if !extFiles.isEmpty {
                isFileOpeningLoading = true
                viewModel.isImporting = false
                self.viewModel.setChosenFiles(.success(extFiles))
                externalFiles = []
            }
        }
    }
}

#Preview {
    MainSignatureView(externalFiles: .constant([]))
}
