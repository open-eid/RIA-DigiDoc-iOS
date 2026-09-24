// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
                    if index > 0 {
                        Divider()
                    }
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
                    if index > 0 {
                        Divider()
                    }
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
