import SwiftUI
import FactoryKit
import UtilsLib

struct RecentDocumentsView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings

    @State private var isFileOpeningLoading = false
    @State private var isNavigatingToSigningView = false
    @State private var isRefreshing = false

    @StateObject private var viewModel: RecentDocumentsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: Container.shared.recentDocumentsViewModel())
    }

    var body: some View {
        VStack {
            HStack {
                TextField(languageSettings.localized("Search container file"), text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled(true)
                    .padding(.leading, 8)
                    .disabled(viewModel.files.count < 2)
                    .opacity(viewModel.files.count < 2 ? 0 : 1.0)
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.loadFiles()
                    }

                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .accessibilityLabel(languageSettings.localized("Remove"))
                    })
                    .padding(.trailing, 8)
                }
            }
            .padding()

            List {
                if viewModel.filteredFiles.isEmpty {
                    Text(
                        viewModel.searchText.isEmpty ? languageSettings.localized("No recent documents") :
                            languageSettings.localized("Document not found")
                    )
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .padding()
                    Spacer()
                } else {
                    ForEach(viewModel.filteredFiles) { file in
                        Button(action: {
                            self.viewModel.setChosenFiles(.success([file.url]))
                            self.isFileOpeningLoading = true
                        }, label: {
                            RecentDocumentFileRow(file: file)
                        })
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: viewModel.deleteFile)
                }
            }
            .refreshable {
                viewModel.loadFiles()
            }
            .fullScreenCover(isPresented: $isFileOpeningLoading) {
                FileOpeningView(
                    isFileOpeningLoading: $isFileOpeningLoading,
                    isNavigatingToNextView: $isNavigatingToSigningView
                )
            }

            NavigationLink(
                destination: SigningView(),
                isActive: $isNavigatingToSigningView
            ) {}
        }
        .navigationTitle(languageSettings.localized("Recent documents"))
        .onAppear {
            viewModel.loadFiles()
        }
    }
}

#Preview {
    RecentDocumentsView()
        .environmentObject(Container.shared.languageSettings())
        .environmentObject(Container.shared.themeSettings())
}
