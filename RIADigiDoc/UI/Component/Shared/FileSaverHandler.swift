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

        switch result {
        case .success:
            isFileSaved = true
            resultMessage = languageSettings.localized("File saved", [])
        case .failure:
            isFileSaved = false
            resultMessage = languageSettings.localized("Failed to save file", [fileURL.lastPathComponent])
        }

        Toast.show(resultMessage)
        isPresented = false
        onComplete?()
    }
}
