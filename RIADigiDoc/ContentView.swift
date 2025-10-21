/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
