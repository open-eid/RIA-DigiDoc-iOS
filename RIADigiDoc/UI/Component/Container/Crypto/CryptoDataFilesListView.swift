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
import LibdigidocLibSwift
import FactoryKit

struct CryptoDataFilesListView: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    let dataFiles: [URL]
    @Binding var selectedDataFile: URL?
    let showOpenFileButton: Bool
    let showSaveFileButton: Bool
    let showRemoveFileButton: Bool
    @Binding var showRemoveDataFileModal: Bool

    let onOpenFileButtonClick: (URL) -> Void
    let onSaveDataFileButtonClick: (URL) -> Void
    let onRemoveFileButtonClick: (URL) -> Void

    var body: some View {
        LazyVStack {
            if #available(iOS 26.0, *) {
                ForEach(dataFiles.enumerated(), id: \.offset) { index, dataFile in
                    CryptoDataFilesView(
                        fileIndex: index + 1,
                        onOpenFileButtonClick: onOpenFileButtonClick,
                        onSaveDataFileButtonClick: onSaveDataFileButtonClick,
                        onRemoveFileButtonClick: onRemoveFileButtonClick,
                        dataFile: dataFile,
                        showOpenFileButton: showOpenFileButton,
                        showSaveFileButton: showSaveFileButton,
                        showRemoveFileButton: showRemoveFileButton,
                        showRemoveDataFileModal: $showRemoveDataFileModal,
                        onSelect: {
                            selectedDataFile = dataFile
                        }
                    )
                }
            } else {
                ForEach(Array(dataFiles.enumerated()), id: \.offset) { index, dataFile in
                    CryptoDataFilesView(
                        fileIndex: index + 1,
                        onOpenFileButtonClick: onOpenFileButtonClick,
                        onSaveDataFileButtonClick: onSaveDataFileButtonClick,
                        onRemoveFileButtonClick: onRemoveFileButtonClick,
                        dataFile: dataFile,
                        showOpenFileButton: showOpenFileButton,
                        showSaveFileButton: showSaveFileButton,
                        showRemoveFileButton: showRemoveFileButton,
                        showRemoveDataFileModal: $showRemoveDataFileModal,
                        onSelect: {
                            selectedDataFile = dataFile
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    // swiftlint:disable force_unwrapping
    let dataFiles = [
        URL(fileURLWithPath: "/preview/path1"),
        URL(fileURLWithPath: "/preview/path2")
    ]

    CryptoDataFilesListView(
        dataFiles: dataFiles,
        selectedDataFile: .constant(dataFiles.first),
        showOpenFileButton: true,
        showSaveFileButton: true,
        showRemoveFileButton: true,
        showRemoveDataFileModal: .constant(false),
        onOpenFileButtonClick: { _ in },
        onSaveDataFileButtonClick: { _ in },
        onRemoveFileButtonClick: { _ in }
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
