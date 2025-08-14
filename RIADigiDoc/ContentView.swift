import FactoryKit
import SwiftUI
import OSLog
import UtilsLib

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppTheme private var theme
    @AppTypography private var typography
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: ContentViewModel

    @State private var openedUrls: [URL] = []
    @State private var showBottomSheetFromButton = false
    @State private var navigateToInfo = false

    private var bottomSheetActions: [BottomSheetButton] {
        HomeMenuBottomSheetActions.actions(
            languageSettings: languageSettings,
            onInfoClick: {
                navigateToInfo = true
            }
        )
    }

    init(
        viewModel: ContentViewModel = Container.shared.contentViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TopBarContainer(
            leftIcon: "ic_m3_menu_48pt_wght400",
            leftIconAccessibility: "Menu",
            onLeftClick: {
                showBottomSheetFromButton = true
            },
            content: {
                VStack {
                    HomeView(externalFiles: $openedUrls)

                    NavigationLink(
                        destination: InfoView(),
                        isActive: $navigateToInfo
                    ) { }

                    Spacer()
                }
                .background(theme.surface)
                .onOpenURL { url in
                    openedUrls = [url]
                }
                .onAppear {
                    if scenePhase == .active {
                        let sharedFiles = viewModel.getSharedFiles()
                        if !sharedFiles.isEmpty {
                            openedUrls = sharedFiles
                        }
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        let sharedFiles = viewModel.getSharedFiles()
                        if !sharedFiles.isEmpty {
                            openedUrls = sharedFiles
                        }
                    }
                }
            }
        )
        .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
