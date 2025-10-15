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

    @State private var sharedFilesLoadingTask: Task<Void, Never>?

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

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.contentViewModel())
    }

    var body: some View {
        TopBarContainer(
            leftIcon: "ic_m3_menu_48pt_wght400",
            leftIconAccessibility: "Menu",
            onLeftClick: {
                showHomeMenuBottomSheetFromButton = true
            },
            content: {
                ScrollView {
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

                        Spacer()
                    }
                }
                .background(theme.surface)
                .onOpenURL { url in
                    openedUrls = [url]
                }
                .onAppear {
                    if scenePhase == .active {
                        sharedFilesLoadingTask = Task {
                            let sharedFiles = viewModel.getSharedFiles()
                            if !sharedFiles.isEmpty {
                                openedUrls = sharedFiles
                            }
                        }
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        sharedFilesLoadingTask?.cancel()

                        sharedFilesLoadingTask = Task {
                            let sharedFiles = viewModel.getSharedFiles()
                            if !sharedFiles.isEmpty {
                                openedUrls = sharedFiles
                            }
                        }
                    }
                }
                .onDisappear {
                    sharedFilesLoadingTask?.cancel()
                }
            }
        )
        .bottomSheet(isPresented: $showHomeMenuBottomSheetFromButton, actions: homeMenuBottomSheetActions)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
