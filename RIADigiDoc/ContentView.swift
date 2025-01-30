import SwiftUI
import OSLog
import UtilsLib

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var languageSettings: LanguageSettings

    @StateObject private var viewModel: ContentViewModel

    @State private var openedUrls: [URL] = []

    init(
        viewModel: ContentViewModel = AppAssembler.shared.resolve(ContentViewModel.self)
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .accessibilityLabel(Text(verbatim: "Globe"))
                    Text(verbatim: "Hello, world!")
                }
                .padding()

                MainSignatureView(externalFiles: $openedUrls)
            }
            .onOpenURL { url in
                openedUrls = [url]
            }
            .onAppear {
                if scenePhase == .active {
                    let sharedFiles = viewModel.getSharedFiles()
                    if !sharedFiles.isEmpty {
                        openedUrls = sharedFiles
                    }
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    let sharedFiles = viewModel.getSharedFiles()
                    if !sharedFiles.isEmpty {
                        openedUrls = sharedFiles
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
