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

struct CryptoImportButton: View {
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

            case .failure:
                isImporting = false
            }
        }
        .fullScreenCover(isPresented: $isFileOpeningLoading) {
            CryptoFileOpeningView(
                isFileOpeningLoading: $isFileOpeningLoading,
                isNavigatingToNextView: $isNavigatingToNextView
            )
        }
    }
}
