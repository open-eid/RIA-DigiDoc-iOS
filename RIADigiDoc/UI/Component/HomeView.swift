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

struct HomeView: View {
    @AppTheme private var theme
    @EnvironmentObject private var languageSettings: LanguageSettings

    @StateObject private var viewModel: HomeViewModel
    @StateObject private var cryptoViewModel: CryptoHomeViewModel
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

    private var cryptoFilesBottomSheetActions: [BottomSheetButton] {
        HomeViewBottomSheetActions.actions(
            onOpenFilesClick: {
                isCryptoImporting = true
            },
            onRecentDocumentsClick: {
                isNavigatingToRecentDocumentsView = true
            }
        )
    }

    init(
        fileOpeningViewModel: FileOpeningViewModel = Container.shared.fileOpeningViewModel(),
        cryptoFileOpeningViewModel: CryptoFileOpeningViewModel = Container.shared.cryptoFileOpeningViewModel(),
        externalFiles: Binding<[URL]>
    ) {
        _viewModel = StateObject(wrappedValue: Container.shared.homeViewModel())
        _cryptoViewModel = StateObject(wrappedValue: Container.shared.cryptoHomeViewModel())
        self.fileOpeningViewModel = fileOpeningViewModel
        self.cryptoFileOpeningViewModel = cryptoFileOpeningViewModel
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
                    title: languageSettings.localized("Signature"),
                    description: languageSettings.localized("Main home signature description"),
                    assetImageName: "ic_m3_stylus_note_48pt_wght400",
                    isFileOpeningLoading: $isFileOpeningLoading,
                    isNavigatingToNextView: $isNavigatingToSigningView,
                    showBottomSheet: $showSignatureBottomSheet,
                    isImporting: $isImporting,
                    viewModel: viewModel
                )
                .bottomSheet(isPresented: $showSignatureBottomSheet, actions: filesBottomSheetActions)

                CryptoImportButton(
                    title: languageSettings.localized("Main home crypto title"),
                    description: languageSettings.localized("Main home crypto description"),
                    assetImageName: "ic_m3_encrypted_48pt_wght400",
                    isFileOpeningLoading: $isCryptoFileOpeningLoading,
                    isNavigatingToNextView: $isNavigatingToEncryptView,
                    showBottomSheet: $showCryptoBottomSheet,
                    isImporting: $isCryptoImporting,
                    viewModel: cryptoViewModel
                )
                .bottomSheet(isPresented: $showCryptoBottomSheet, actions: cryptoFilesBottomSheetActions)

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
                destination: EncryptView(),
                isActive: $isNavigatingToEncryptView
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
