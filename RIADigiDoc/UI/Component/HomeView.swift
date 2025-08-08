import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct HomeView: View {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: HomeViewModel
    private var fileOpeningViewModel: FileOpeningViewModel

    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var isNavigatingToRecentDocumentsView = false

    @Binding private var externalFiles: [URL]

    init(
        viewModel: HomeViewModel = Container.shared.homeViewModel(),
        fileOpeningViewModel: FileOpeningViewModel = Container.shared.fileOpeningViewModel(),
        externalFiles: Binding<[URL]>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.fileOpeningViewModel = fileOpeningViewModel
        self._externalFiles = externalFiles
    }

    var body: some View {
        VStack {
            HomeHeader()
                .padding(.bottom, Dimensions.Padding.LPadding)
            
            VStack(spacing: Dimensions.Padding.SPadding) {
                ActionButton(
                    title: languageSettings.localized("Main home open document title"),
                    description: languageSettings.localized("Main home open document description"),
                    assetImageName: "ic_m3_attach_file_48pt_wght400",
                ) {
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
                
                ActionButton(
                    title: languageSettings.localized("Main home signature title"),
                    description: languageSettings.localized("Main home signature description"),
                    assetImageName: "ic_m3_stylus_note_48pt_wght400",
                ) {}
                ActionButton(
                    title: languageSettings.localized("Main home crypto title"),
                    description: languageSettings.localized("Main home crypto description"),
                    assetImageName: "ic_m3_encrypted_48pt_wght400",
                ) {}
                ActionButton(
                    title: languageSettings.localized("Main home my eid title"),
                    description: languageSettings.localized("Main home my eid description"),
                    assetImageName: "ic_m3_co_present_48pt_wght400",
                ) {}
            }
            .padding(Dimensions.Padding.SPadding)
            
            NavigationLink(
                destination: SigningView(),
                isActive: $isNavigatingToSigningView
            ) {}
            
            Spacer()
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
    HomeView(externalFiles: .constant([]))
        .environmentObject(
            Container.shared.languageSettings()
        )
}
