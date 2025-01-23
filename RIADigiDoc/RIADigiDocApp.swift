import SwiftUI
import LibdigidocLibSwift
import UtilsLib

@main
struct RIADigiDocApp: App {
    @StateObject private var languageSettings = LanguageSettings()
    @State private var isSetupComplete = false
    @State private var isJailbroken: Bool = false

    init() {}

    var body: some Scene {
        WindowGroup {
            if isJailbroken {
                JailbreakView()
            } else if isSetupComplete {
                ContentView()
                    .environmentObject(languageSettings)
            } else {
                LaunchScreenView()
                    .onAppear {
                        Task {
                            if await JailbreakDetection.isDeviceJailbroken() {
                                await MainActor.run {
                                    self.isJailbroken = true
                                }
                                return
                            }

                            await setupAssemblers()

                            let librarySetup = AppAssembler.shared.resolve(LibrarySetup.self)
                            await librarySetup.setupLibraries()
                            await MainActor.run {
                                self.isSetupComplete = true
                            }
                        }
                    }
            }
        }
    }

    private func setupAssemblers() async {
        await AppAssembler.shared.initialize()
        await LibDigidocAssembler.shared.initialize()
        await UtilsLibAssembler.shared.initialize()
    }
}
