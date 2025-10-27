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
import CommonsLib

struct RenameModalView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @ObservedObject var signingViewModel: SigningViewModel
    @Binding var showRenameModal: Bool
    @Binding var newContainerName: String

    var body: some View {
        ZStack {
            // Make the background darker to focus on the dialog
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()

            InputModal(
                icon: "ic_m3_edit_48pt_wght400",
                title: languageSettings.localized("Change container name"),
                placeholder: signingViewModel.containerName,
                text: Binding<String>(
                    get: {
                        URL(fileURLWithPath: signingViewModel.containerName)
                            .deletingPathExtension()
                            .lastPathComponent
                    },
                    set: { newValue in
                        let existingExtension = URL(fileURLWithPath: signingViewModel.containerName).pathExtension
                        let newValueURL = URL(fileURLWithPath: newValue)

                        let containerExtension =
                        existingExtension.isEmpty ? Constants.Extension.Default : existingExtension

                        newContainerName = newValueURL
                            .appendingPathExtension(containerExtension)
                            .lastPathComponent
                    }),
                onConfirm: {
                    showRenameModal = false
                    Task {
                        let uniqueContainerName = await signingViewModel.renameContainer(to: newContainerName)
                        defer { newContainerName = "" }

                        if let uniqueContainerName {
                            signingViewModel.containerName = uniqueContainerName.lastPathComponent
                        }
                    }
                },
                onCancel: {
                    showRenameModal = false
                    newContainerName = ""
                }
            )
        }
    }
}
