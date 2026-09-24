// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit

struct SigningImportButton: View {
    let title: String
    let titleAccessibility: String
    let description: String
    let assetImageName: String
    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToSigningView: Bool
    @Binding var isNavigatingToEncryptView: Bool
    @Binding var showBottomSheet: Bool

    @Binding var isImporting: Bool
    var fileOpeningMethod: FileOpeningMethod

    @State private var viewModel: HomeViewModel

    init(
        title: String,
        titleAccessibility: String = "",
        description: String,
        assetImageName: String,
        isFileOpeningLoading: Binding<Bool>,
        isNavigatingToSigningView: Binding<Bool>,
        isNavigatingToEncryptView: Binding<Bool>,
        showBottomSheet: Binding<Bool>,
        isImporting: Binding<Bool>,
        viewModel: HomeViewModel,
        fileOpeningMethod: FileOpeningMethod
    ) {
        self.title = title
        self.titleAccessibility = titleAccessibility
        self.description = description
        self.assetImageName = assetImageName
        self._isFileOpeningLoading = isFileOpeningLoading
        self._isNavigatingToSigningView = isNavigatingToSigningView
        self._isNavigatingToEncryptView = isNavigatingToEncryptView
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

            case .failure:
                isImporting = false
            }
        }
        .fullScreenCover(isPresented: $isFileOpeningLoading) {
            FileOpeningView(
                isFileOpeningLoading: $isFileOpeningLoading,
                isNavigatingToSigningView: $isNavigatingToSigningView,
                isNavigatingToEncryptView: $isNavigatingToEncryptView
            )
        }
    }
}
