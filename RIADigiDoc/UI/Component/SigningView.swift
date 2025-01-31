import SwiftUI
import LibdigidocLibSwift

struct SigningView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var languageSettings: LanguageSettings

    @State private var selectedSignature: SignatureWrapper?

    @StateObject private var viewModel: SigningViewModel
    @State private var tempContainerURL: URL?
    @State private var isShowingFileSaver = false
    @State private var alertMessage: String?
    @State private var isFileSaved: Bool = false
    @State private var showAlert: Bool = false

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

            HStack {
                Text(String(format: languageSettings.localized("Container: %@"), viewModel.containerName))
                SaveButton(action: {
                    Task {
                        tempContainerURL = viewModel.createCopyOfContainerForSaving(
                            containerURL: viewModel.containerURL
                        )

                        if viewModel.checkIfContainerFileExists(fileLocation: tempContainerURL) {
                            isShowingFileSaver = true
                        }
                    }
                }).fileMover(isPresented: $isShowingFileSaver, file: tempContainerURL) { result in
                    switch result {
                    case .success:
                        isFileSaved = true
                        alertMessage = languageSettings.localized("File saved")
                    case .failure:
                        isFileSaved = false
                        alertMessage = languageSettings.localized("Failed to save file")
                    }
                    isShowingFileSaver = false
                    showAlert = true
                    viewModel.removeSavedFilesDirectory()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: isFileSaved ? Text(languageSettings.localized("Done")) :
                            Text(languageSettings.localized("Error")),
                        message: Text(alertMessage ??
                                      languageSettings.localized("General error")),
                        dismissButton: .default(Text(languageSettings.localized("OK")))
                    )
                }
            }

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
            }
        }
    }
}

#Preview {
    SigningView()
}
