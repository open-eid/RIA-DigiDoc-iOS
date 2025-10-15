import SwiftUI
import FactoryKit
import LibdigidocLibSwift

struct HomeView: View {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: HomeViewModel
    private var fileOpeningViewModel: FileOpeningViewModel

    @State private var isImporting = false
    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var isNavigatingToRecentDocumentsView = false

    @State private var showFilesBottomSheet: Bool = false
    @State private var showSignatureBottomSheet: Bool = false

    @Binding private var externalFiles: [URL]

    private var filesBottomSheetActions: [BottomSheetButton] {
        HomeViewBottomSheetActions.actions(
            onOpenFilesClick: {
                isImporting = true
            },
            onRecentDocumentsClick: {
                isNavigatingToRecentDocumentsView = true
            }
        )
    }

    init(
        fileOpeningViewModel: FileOpeningViewModel = Container.shared.fileOpeningViewModel(),
        externalFiles: Binding<[URL]>
    ) {
        _viewModel = StateObject(wrappedValue: Container.shared.homeViewModel())
        self.fileOpeningViewModel = fileOpeningViewModel
        self._externalFiles = externalFiles
    }

    var body: some View {
        VStack {
            HomeHeader()
                .padding(.bottom, Dimensions.Padding.LPadding)

            VStack(spacing: Dimensions.Padding.SPadding) {
                SigningImportButton(
                    title: languageSettings.localized("Main home open document title"),
                    description: languageSettings.localized("Main home open document description"),
                    assetImageName: "ic_m3_attach_file_48pt_wght400",
                    isFileOpeningLoading: $isFileOpeningLoading,
                    isNavigatingToNextView: $isNavigatingToSigningView,
                    showBottomSheet: $showFilesBottomSheet,
                    isImporting: $isImporting,
                    viewModel: viewModel
                )
                .bottomSheet(isPresented: $showFilesBottomSheet, actions: filesBottomSheetActions)

                SigningImportButton(
                    title: languageSettings.localized("Main home signature title"),
                    description: languageSettings.localized("Main home signature description"),
                    assetImageName: "ic_m3_stylus_note_48pt_wght400",
                    isFileOpeningLoading: $isFileOpeningLoading,
                    isNavigatingToNextView: $isNavigatingToSigningView,
                    showBottomSheet: $showSignatureBottomSheet,
                    isImporting: $isImporting,
                    viewModel: viewModel
                )
                .bottomSheet(isPresented: $showSignatureBottomSheet, actions: filesBottomSheetActions)

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

            NavigationLink(
                destination: RecentDocumentsView(),
                isActive: $isNavigatingToRecentDocumentsView
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
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
