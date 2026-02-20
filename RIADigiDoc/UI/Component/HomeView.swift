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

import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import CommonsLib
import UtilsLib

struct HomeView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    @Environment(\.scenePhase) private var scenePhase
    @Environment(LanguageSettings.self) private var languageSettings
    @Environment(NavigationPathManager.self) private var pathManager

    @State private var viewModel: HomeViewModel
    @State private var cryptoViewModel: CryptoHomeViewModel
    private var fileOpeningViewModel: FileOpeningViewModel
    private var cryptoFileOpeningViewModel: CryptoFileOpeningViewModel

    @State private var isImporting = false
    @State private var isCryptoImporting = false
    @State private var isFileOpeningLoading = false
    @State private var isCryptoFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var isNavigatingToRecentDocumentsView = false
    @State private var isNavigatingToEncryptView = false

    @State private var showFilesBottomSheet: Bool = false
    @State private var showSignatureBottomSheet: Bool = false
    @State private var showCryptoBottomSheet: Bool = false
    @State private var showHomeMenuBottomSheet: Bool = false

    @State private var containerType: ContainerType = .asice
    @State private var recentDocumentsExtensions: [String] = Constants.Container.ContainerExtensions

    @State private var sharedFilesLoadingTask: Task<Void, Never>?
    @AccessibilityFocusState private var isFilesButtonFocused: Bool

    private var allContainerFilesBottomSheetActions: [BottomSheetButton] {
        HomeViewBottomSheetActions.actions(
            onOpenFilesClick: {
                isImporting = true
            },
            onRecentDocumentsClick: {
                containerType = .none
                recentDocumentsExtensions =
                    Constants.Container.ContainerExtensions + Constants.Container.CryptoContainerExtensions
                pathManager.navigate(to:
                        .recentDocumentsView(
                            folderURL: getRecentDocumentsFolder(containerType: containerType),
                            extensions: recentDocumentsExtensions
                        )
                )
            }
        )
    }

    private var signedFilesBottomSheetActions: [BottomSheetButton] {
        HomeViewBottomSheetActions.actions(
            onOpenFilesClick: {
                isImporting = true
            },
            onRecentDocumentsClick: {
                containerType = .asice
                recentDocumentsExtensions = Constants.Container.ContainerExtensions
                pathManager.navigate(to:
                        .recentDocumentsView(
                            folderURL: getRecentDocumentsFolder(containerType: containerType),
                            extensions: recentDocumentsExtensions
                        )
                )
            }
        )
    }

    private var cryptoFilesBottomSheetActions: [BottomSheetButton] {
        HomeViewBottomSheetActions.actions(
            onOpenFilesClick: {
                isCryptoImporting = true
            },
            onRecentDocumentsClick: {
                containerType = .cdoc
                recentDocumentsExtensions = Constants.Container.CryptoContainerExtensions
                pathManager.navigate(to:
                        .recentDocumentsView(
                            folderURL: getRecentDocumentsFolder(containerType: containerType),
                            extensions: recentDocumentsExtensions
                        )
                )
            }
        )
    }

    private var homeMenuBottomSheetActions: [BottomSheetButton] {
        HomeMenuBottomSheetActions.actions(
            onInfoClick: {
                pathManager.navigate(to: .infoView)
            },
            onAccessibilityClick: {
                pathManager.navigate(to: .accessibilityView)
            },
            onDiagnosticsClick: {
                pathManager.navigate(to: .diagnosticsView)
            }
        )
    }

    private var isBottomSheetPresented: Bool {
        showFilesBottomSheet || showSignatureBottomSheet || showCryptoBottomSheet || showHomeMenuBottomSheet
    }

    init(
        fileOpeningViewModel: FileOpeningViewModel = Container.shared.fileOpeningViewModel(),
        cryptoFileOpeningViewModel: CryptoFileOpeningViewModel = Container.shared.cryptoFileOpeningViewModel(),
    ) {
        _viewModel = State(wrappedValue: Container.shared.homeViewModel())
        _cryptoViewModel = State(wrappedValue: Container.shared.cryptoHomeViewModel())
        self.fileOpeningViewModel = fileOpeningViewModel
        self.cryptoFileOpeningViewModel = cryptoFileOpeningViewModel
    }

    var body: some View {
        TopBarContainer(
            leftIcon: "ic_m3_menu_48pt_wght400",
            leftIconAccessibility: "Menu",
            onLeftClick: {
                showHomeMenuBottomSheet = true
            },
            onSettingsSheetDismiss: {
                focusFilesButtonWithDelay()
            },
            content: {
                ScrollView {
                    HomeHeader()
                        .padding(.bottom, Dimensions.Padding.LPadding)

                    VStack(spacing: Dimensions.Padding.SPadding) {
                        SigningImportButton(
                            title: languageSettings.localized("Main home open document title"),
                            description: languageSettings.localized("Main home open document description"),
                            assetImageName: "ic_m3_attach_file_48pt_wght400",
                            isFileOpeningLoading: $isFileOpeningLoading,
                            isNavigatingToSigningView: $isNavigatingToSigningView,
                            isNavigatingToEncryptView: $isNavigatingToEncryptView,
                            showBottomSheet: $showFilesBottomSheet,
                            isImporting: $isImporting,
                            viewModel: viewModel,
                            fileOpeningMethod: .all
                        )
                        .bottomSheet(isPresented: $showFilesBottomSheet, actions: allContainerFilesBottomSheetActions)
                        .accessibilityFocused($isFilesButtonFocused)

                        SigningImportButton(
                            title: languageSettings.localized("Signature"),
                            description: languageSettings.localized("Main home signature description"),
                            assetImageName: "ic_m3_stylus_note_48pt_wght400",
                            isFileOpeningLoading: $isFileOpeningLoading,
                            isNavigatingToSigningView: $isNavigatingToSigningView,
                            isNavigatingToEncryptView: $isNavigatingToEncryptView,
                            showBottomSheet: $showSignatureBottomSheet,
                            isImporting: $isImporting,
                            viewModel: viewModel,
                            fileOpeningMethod: .signing
                        )
                        .bottomSheet(isPresented: $showSignatureBottomSheet, actions: signedFilesBottomSheetActions)

                        CryptoImportButton(
                            title: languageSettings.localized("Main home crypto title"),
                            description: languageSettings.localized("Main home crypto description"),
                            assetImageName: "ic_m3_encrypted_48pt_wght400",
                            isFileOpeningLoading: $isCryptoFileOpeningLoading,
                            isNavigatingToNextView: $isNavigatingToEncryptView,
                            showBottomSheet: $showCryptoBottomSheet,
                            isImporting: $isCryptoImporting,
                            viewModel: cryptoViewModel,
                            fileOpeningMethod: .crypto
                        )
                        .bottomSheet(isPresented: $showCryptoBottomSheet, actions: cryptoFilesBottomSheetActions)

                        ActionButton(
                            title: languageSettings.localized("Main home my eid title"),
                            description: languageSettings.localized("Main home my eid description"),
                            assetImageName: "ic_m3_co_present_48pt_wght400",
                            action: {
                                pathManager.navigate(to: .myEidRootView)
                            }
                        )
                    }
                    .padding(Dimensions.Padding.SPadding)

                    Spacer()
                }
            }
        )
        .bottomSheet(isPresented: $showHomeMenuBottomSheet, actions: homeMenuBottomSheetActions)
        .onOpenURL { url in
            handleFiles([url])
        }
        .onAppear {
            focusFilesButtonWithDelay()
            if scenePhase == .active {
                loadSharedFiles()
            }
        }
        .onChange(of: isNavigatingToSigningView, { _, newValue in
            if newValue {
                pathManager.navigate(to: .signingView)
                isNavigatingToSigningView = false
            }
        })
        .onChange(of: isNavigatingToEncryptView, { _, newValue in
            if newValue {
                pathManager.navigate(to: .encryptView(
                    isWithEncryption: false
                ))
                isNavigatingToEncryptView = false
            }
        })
        .onChange(of: isBottomSheetPresented) { oldValue, newValue in
            if oldValue && !newValue {
                focusFilesButtonWithDelay()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                sharedFilesLoadingTask?.cancel()
                loadSharedFiles()
            }
        }
        .onDisappear {
            sharedFilesLoadingTask?.cancel()
        }
    }

    private func focusFilesButtonWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFilesButtonFocused = true
        }
    }

    func getRecentDocumentsFolder(containerType: ContainerType) -> URL? {
        switch containerType {
        case .cdoc:
            return cryptoViewModel.getRecentDocumentsFolder()
        default:
            return viewModel.getRecentDocumentsFolder()
        }
    }

    private func loadSharedFiles() {
        sharedFilesLoadingTask = Task {
            let sharedFiles = await viewModel.getSharedFiles()
            handleFiles(sharedFiles)
        }
    }

    private func handleFiles(_ files: [URL]) {
        if !files.isEmpty {
            isFileOpeningLoading = true
            viewModel.isImporting = false
            viewModel.setChosenFiles(.success(files))
        }
    }
}

#Preview {
    HomeView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
