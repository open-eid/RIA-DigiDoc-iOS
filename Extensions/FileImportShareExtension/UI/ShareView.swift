import SwiftUI
import FactoryKit

struct ShareView: View {
    @StateObject private var viewModel: ShareViewModel
    var statusChanged: (() -> Void)?
    var completeRequest: (() -> Void)?

    var languageSettings: LanguageSettings

    init(
        statusChanged: (() -> Void)? = nil,
        completeRequest: (() -> Void)? = nil,
        languageSettings: LanguageSettings = LanguageSettings(dataStore: DataStore())
    ) {
        _viewModel = StateObject(wrappedValue: Container.shared.shareViewModel())
        self.statusChanged = statusChanged
        self.completeRequest = completeRequest
        self.languageSettings = languageSettings
    }

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
    ShareView {}
}
