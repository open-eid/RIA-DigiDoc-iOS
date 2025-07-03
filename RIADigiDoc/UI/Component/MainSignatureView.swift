import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct MainSignatureView: View {

    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: MainSignatureViewModel
    private var fileOpeningViewModel: FileOpeningViewModel

    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var isNavigatingToRecentDocumentsView = false

    @Binding private var externalFiles: [URL]

    init(
        viewModel: MainSignatureViewModel = Container.shared.mainSignatureViewModel(),
        fileOpeningViewModel: FileOpeningViewModel = Container.shared.fileOpeningViewModel(),
        externalFiles: Binding<[URL]>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.fileOpeningViewModel = fileOpeningViewModel
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
                    viewModel: fileOpeningViewModel,
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
        .environmentObject(
            Container.shared.languageSettings()
        )
}
