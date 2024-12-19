import SwiftUI

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel
    var statusChanged: (() -> Void)?
    var completeRequest: (() -> Void)?

    var languageSettings = LanguageSettings()

    var body: some View {
        VStack {
            switch viewModel.status {
            case .processing:
                Text(languageSettings.localized("Share Extension Import Progress"))
                    .font(.headline)
                    .padding()
                    .onAppear {
                        statusChanged?()
                    }
            case .imported:
                Text(languageSettings.localized("Share Extension Import Completed"))
                    .font(.headline)
                    .padding()
                Button("OK") {
                    completeRequest?()
                }
            case .failed:
                Text(languageSettings.localized("Share Extension Import Failed"))
                    .font(.headline)
                    .padding()
                Button("OK") {
                    completeRequest?()
                }
            }
        }
    }
}

#Preview {
    ShareView(viewModel: ShareViewModel()) {}
}
