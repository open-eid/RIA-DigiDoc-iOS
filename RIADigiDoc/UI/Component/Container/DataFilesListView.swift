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
import LibdigidocLibSwift
import FactoryKit

struct DataFilesListView: View {
    @Environment(LanguageSettings.self) private var languageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    let dataFiles: [DataFileWrapper]
    @Binding var selectedDataFile: DataFileWrapper?
    let showRemoveFileButton: Bool
    @Binding var showRemoveDataFileModal: Bool

    let onOpenFileButtonClick: (DataFileWrapper) -> Void
    let onSaveDataFileButtonClick: (DataFileWrapper) -> Void
    let onRemoveFileButtonClick: (DataFileWrapper) -> Void

    var body: some View {
        LazyVStack {
            if #available(iOS 26.0, *) {
                ForEach(dataFiles.enumerated(), id: \.offset) { index, dataFile in
                    if index > 0 {
                        Divider()
                    }
                    DataFilesView(
                        fileIndex: index + 1,
                        onOpenFileButtonClick: onOpenFileButtonClick,
                        onSaveDataFileButtonClick: onSaveDataFileButtonClick,
                        onRemoveFileButtonClick: onRemoveFileButtonClick,
                        dataFile: dataFile,
                        showRemoveFileButton: showRemoveFileButton,
                        showRemoveDataFileModal: $showRemoveDataFileModal,
                        onSelect: {
                            selectedDataFile = dataFile
                        }
                    )
                }
            } else {
                ForEach(Array(dataFiles.enumerated()), id: \.offset) { index, dataFile in
                    if index > 0 {
                        Divider()
                    }
                    DataFilesView(
                        fileIndex: index + 1,
                        onOpenFileButtonClick: onOpenFileButtonClick,
                        onSaveDataFileButtonClick: onSaveDataFileButtonClick,
                        onRemoveFileButtonClick: onRemoveFileButtonClick,
                        dataFile: dataFile,
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
    let dataFiles = [
        DataFileWrapper(
            id: UUID(),
            fileId: "1",
            fileName: "DataFile1.txt",
            fileSize: 123,
            mediaType: "text/plain"
        ),
        DataFileWrapper(
            id: UUID(),
            fileId: "2",
            fileName: "DataFile2.txt",
            fileSize: 456,
            mediaType: "text/plain"
        )
    ]

    DataFilesListView(
        dataFiles: dataFiles,
        selectedDataFile: .constant(dataFiles.first),
        showRemoveFileButton: true,
        showRemoveDataFileModal: .constant(false),
        onOpenFileButtonClick: { _ in },
        onSaveDataFileButtonClick: { _ in },
        onRemoveFileButtonClick: { _ in }
    )
    .environment(Container.shared.languageSettings())
    .environment(Container.shared.themeSettings())
}
