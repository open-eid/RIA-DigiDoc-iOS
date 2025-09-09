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
    @State private var showHomeMenuBottomSheetFromButton = false
    @State private var showSettingsBottomSheetFromButton = false

    @State private var navigateToAccessibility = false
    @State private var navigateToInfo = false
    @State private var navigateToDiagnostics = false

    @State private var navigateToLanguageChooser = false

    private var homeMenuBottomSheetActions: [BottomSheetButton] {
        HomeMenuBottomSheetActions.actions(
            onInfoClick: {
                navigateToInfo = true
            },
            onAccessibilityClick: {
                navigateToAccessibility = true
            },
            onDiagnosticsClick: {
                navigateToDiagnostics = true
            }
        )
    }

    private var settingsBottomSheetActions: [BottomSheetButton] {
        SettingsMenuBottomSheetActions.actions(
            onLanguageChooserClick: {
                navigateToLanguageChooser = true
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
                showHomeMenuBottomSheetFromButton = true
            },
            onRightSecondaryClick: {
                showSettingsBottomSheetFromButton = true
            },
            content: {
                VStack {
                    HomeView(externalFiles: $openedUrls)

                    NavigationLink(
                        destination: InfoView(),
                        isActive: $navigateToInfo
                    ) { }
                    NavigationLink(
                        destination: AccessibilityView(),
                        isActive: $navigateToAccessibility
                    ) { }
                    NavigationLink(
                        destination: DiagnosticsView(),
                        isActive: $navigateToDiagnostics
                    ) { }

                    NavigationLink(
                        destination: LanguageChooserView(),
                        isActive: $navigateToLanguageChooser
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
        .bottomSheet(isPresented: $showHomeMenuBottomSheetFromButton, actions: homeMenuBottomSheetActions)
        .bottomSheet(isPresented: $showSettingsBottomSheetFromButton, actions: settingsBottomSheetActions)

    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(
            Container.shared.languageSettings()
        )
}
