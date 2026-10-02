/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

struct SigningImportButton: View {
    @Environment(LanguageSettings.self) private var languageSettings

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

            case .failure(let error):
                isImporting = false
                viewModel.handleFileImportFailure(error)
                showFileImportFailureMessage()
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

    private func showFileImportFailureMessage() {
        let message = languageSettings.localized("Could not load selected files")
        Toast.show(message)
        AccessibilityUtil.announceMessage(message)
    }
}
