// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct CryptoImportButton: View {
    @Environment(LanguageSettings.self) private var languageSettings

    let title: String
    let titleAccessibility: String
    let description: String
    let assetImageName: String
    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToNextView: Bool
    @Binding var showBottomSheet: Bool

    @Binding var isImporting: Bool
    var fileOpeningMethod: FileOpeningMethod

    @State private var viewModel: CryptoHomeViewModel

    init(
        title: String,
        titleAccessibility: String = "",
        description: String,
        assetImageName: String,
        isFileOpeningLoading: Binding<Bool>,
        isNavigatingToNextView: Binding<Bool>,
        showBottomSheet: Binding<Bool>,
        isImporting: Binding<Bool>,
        viewModel: CryptoHomeViewModel,
        fileOpeningMethod: FileOpeningMethod
    ) {
        self.title = title
        self.titleAccessibility = titleAccessibility
        self.description = description
        self.assetImageName = assetImageName
        self._isFileOpeningLoading = isFileOpeningLoading
        self._isNavigatingToNextView = isNavigatingToNextView
        self._showBottomSheet = showBottomSheet
        self._isImporting = isImporting
        self.viewModel = viewModel
        self.fileOpeningMethod = fileOpeningMethod
    }

    var body: some View {
        ActionButton(
            title: title,
            titleAccessibility: titleAccessibility,
            description: description,
            assetImageName: assetImageName
        ) {
            showBottomSheet = true
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else { continue }
                }

                isFileOpeningLoading = true
                isImporting = false
                viewModel.setChosenFiles(result)
                viewModel.setFileOpeningMethod(fileOpeningMethod)

                for url in urls {
                    url.stopAccessingSecurityScopedResource()
                }

            case .failure(let error):
                isImporting = false
                viewModel.handleFileImportFailure(error)
                showFileImportFailureMessage()
            }
        }
        .fullScreenCover(isPresented: $isFileOpeningLoading) {
            CryptoFileOpeningView(
                isFileOpeningLoading: $isFileOpeningLoading,
                isNavigatingToNextView: $isNavigatingToNextView
            )
        }
    }

    private func showFileImportFailureMessage() {
        let message = languageSettings.localized("Could not load selected files")
        Toast.show(message)
        AccessibilityUtil.announceMessage(message)
    }
}
