import SwiftUI
import FactoryKit

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel
    var statusChanged: (() -> Void)?
    var completeRequest: (() -> Void)?

    var languageSettings: LanguageSettings

    init(
        viewModel: ShareViewModel = Container.shared.shareViewModel(),
        statusChanged: (() -> Void)? = nil,
        completeRequest: (() -> Void)? = nil,
        languageSettings: LanguageSettings = LanguageSettings(dataStore: DataStore())
    ) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
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
