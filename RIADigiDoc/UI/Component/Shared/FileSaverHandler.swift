// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct FileSaverHandler: View {
    @Binding var isPresented: Bool
    let fileURL: URL?
    let languageSettings: LanguageSettings
    let onComplete: (() -> Void)?
    @Binding var isFileSaved: Bool

    var body: some View {
        Group {
            if let fileURL {
                Color.clear
                    .fileMover(isPresented: $isPresented, file: fileURL) { result in
                        handleFileMoveResult(result, fileURL: fileURL)
                    }
            } else {
                Color.clear
                    .onAppear {
                        isPresented = false
                    }
            }
        }
    }

    private func handleFileMoveResult(_ result: Result<URL, Error>, fileURL: URL) {
        let resultMessage: String
        let toastType: ToastType

        switch result {
        case .success:
            isFileSaved = true
            toastType = .success
            resultMessage = languageSettings.localized("File saved", [])
        case .failure:
            isFileSaved = false
            toastType = .error
            resultMessage = languageSettings.localized("Failed to save file", [fileURL.lastPathComponent])
        }

        Toast.show(resultMessage, type: toastType)
        isPresented = false
        onComplete?()
    }
}
