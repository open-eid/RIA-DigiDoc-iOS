import SwiftUI

@main
struct RIADigiDocApp: App {
    @State private var isSetupComplete = false

    init() {}

    var body: some Scene {
        WindowGroup {
            if isSetupComplete {
                ContentView()
            } else {
                LaunchScreenView()
                    .onAppear {
                        Task {
                            await AppAssembler.shared.initialize()
                            await self.initializeLibdigidoc()
                            await MainActor.run {
                                self.isSetupComplete = true
                            }
                        }
                    }
            }
        }
    }

    func initializeLibdigidoc() async {
        let librarySetup = AppAssembler.shared.resolve(LibrarySetup.self)
        await librarySetup.setupLibraries()
    }
}
