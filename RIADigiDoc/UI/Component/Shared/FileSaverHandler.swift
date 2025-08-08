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
            resultMessage = String(
                format: languageSettings.localized("File %@ saved"),
                fileURL.lastPathComponent
            )
        case .failure:
            isFileSaved = false
            resultMessage = String(
                format: languageSettings.localized("Failed to save file %@"),
                fileURL.lastPathComponent
            )
        }

        Toast.show(resultMessage)
        isPresented = false
        onComplete?()
    }
}
