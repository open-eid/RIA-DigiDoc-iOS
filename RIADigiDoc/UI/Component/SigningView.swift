import SwiftUI
import LibdigidocLibSwift

struct SigningView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageSettings: LanguageSettings

    @StateObject private var viewModel: SigningViewModel

    init(
        viewModel: SigningViewModel = AppAssembler.shared.resolve(SigningViewModel.self)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Text("Signing")
                .font(.headline)

            Spacer()

            Text("Container: \(viewModel.containerName)")

            Spacer()

            Text("Container files")
            List(viewModel.dataFiles, id: \.self) { dataFile in
                Text(dataFile.fileName)
            }

            Text("Container signatures")
            List(viewModel.signatures, id: \.self) { signature in
                Text(signature.signedBy)
                Text(signature.status.rawValue)
                Text(signature.trustedSigningTime)
            }

            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.loadContainerData(
                    signedContainer: viewModel.sharedContainerViewModel.getSignedContainer()
                )
            }
        }
    }
}

#Preview {
    SigningView()
}
