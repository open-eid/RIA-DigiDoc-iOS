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

struct RenameModalView: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var containerName: String
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    private var title: String {
        languageSettings.localized("Change container name")
    }

    private var placeholder: String {
        containerName.isEmpty ? languageSettings.localized("Container name") : containerName
    }

    init(
        containerName: String,
        onConfirm: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
    ) {
        self.containerName = containerName
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        ZStack {
            // Make the background darker to focus on the dialog
            Color.black
                .opacity(Dimensions.Shadow.LOpacity)
                .ignoresSafeArea()

            InputModal(
                icon: "ic_m3_edit_48pt_wght400",
                title: title,
                placeholder: placeholder,
                text: $containerName,
                onConfirm: { onConfirm(containerName) },
                onCancel: onCancel
            )
        }
    }
}
