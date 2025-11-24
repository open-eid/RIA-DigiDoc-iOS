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

struct CryptoImportButton: View {
    let title: String
    let description: String
    let assetImageName: String
    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToNextView: Bool
    @Binding var showBottomSheet: Bool

    @Binding var isImporting: Bool
    @ObservedObject var viewModel: CryptoHomeViewModel

    var body: some View {
        ActionButton(
            title: title,
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
