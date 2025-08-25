import SwiftUI

struct SigningImportButton: View {
    let title: String
    let description: String
    let assetImageName: String
    @Binding var isFileOpeningLoading: Bool
    @Binding var isNavigatingToNextView: Bool

    @State private var isImporting: Bool = false
    @ObservedObject var viewModel: HomeViewModel
    var fileOpeningViewModel: FileOpeningViewModel

    var body: some View {
        ActionButton(
            title: title,
            description: description,
            assetImageName: assetImageName
        ) {
            isImporting = true
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else { continue }
                }

                isFileOpeningLoading = true
                isImporting = false
                viewModel.setChosenFiles(result)

                for url in urls {
                    url.stopAccessingSecurityScopedResource()
                }

            case .failure:
                isImporting = false
            }
        }
        .fullScreenCover(isPresented: $isFileOpeningLoading) {
            FileOpeningView(
                viewModel: fileOpeningViewModel,
                isFileOpeningLoading: $isFileOpeningLoading,
                isNavigatingToNextView: $isNavigatingToNextView
            )
        }
    }
}
