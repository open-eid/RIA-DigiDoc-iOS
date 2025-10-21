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

struct DataFilesListView: View {
    @AppTheme private var theme
    @AppTypography private var typography

    let dataFiles: [DataFileWrapper]
    let showRemoveFileButton: Bool

    let onOpenFileButtonClick: (DataFileWrapper) -> Void
    let onSaveDataFileButtonClick: (DataFileWrapper) -> Void

    var body: some View {
        List(dataFiles, id: \.self) { dataFile in
            DataFilesView(
                onOpenFileButtonClick: onOpenFileButtonClick,
                onSaveDataFileButtonClick: onSaveDataFileButtonClick,
                dataFile: dataFile,
                showRemoveFileButton: showRemoveFileButton
            )
        }
        .listStyle(.plain)
    }
}

#Preview {
    DataFilesListView(
        dataFiles: [
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
        ],
        showRemoveFileButton: true,
        onOpenFileButtonClick: { _ in },
        onSaveDataFileButtonClick: { _ in }
    )
    .environmentObject(Container.shared.themeSettings())
}
