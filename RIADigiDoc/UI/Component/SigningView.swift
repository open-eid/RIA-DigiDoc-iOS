import SwiftUI
import LibdigidocLibSwift

struct SigningView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageSettings: LanguageSettings

    @State private var selectedSignature: SignatureWrapper?

    @StateObject private var viewModel: SigningViewModel

    init(
        viewModel: SigningViewModel = AppAssembler.shared.resolve(SigningViewModel.self)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Text(languageSettings.localized("Signing"))
                .font(.headline)

            Spacer()

            Text(String(format: languageSettings.localized("Container: %@"), viewModel.containerName))

            Spacer()

            Text(languageSettings.localized("Container files"))
            DataFilesListView(dataFiles: viewModel.dataFiles)

            Text(languageSettings.localized("Container signatures"))
            SignaturesListView(
                signatures: viewModel.signatures,
                selectedSignature: $selectedSignature,
                containerMimetype: $viewModel.containerMimetype,
                dataFilesCount: viewModel.dataFiles.count
            )

            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.loadContainerData(
                    signedContainer: viewModel.sharedContainerViewModel.getSignedContainer()
                )

                await viewModel.loadContainerMimetype()
            }
        }
    }
}

#Preview {
    SigningView()
}
