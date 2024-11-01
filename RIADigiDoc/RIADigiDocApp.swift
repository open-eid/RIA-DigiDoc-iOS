import SwiftUI
import LibdigidoclibSwift

@main
struct RIADigiDocApp: App {

    let librarySetup = AppAssembler.shared.resolve(LibrarySetup.self)

    init() {
        initializeLibdigidoc()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    func initializeLibdigidoc() {
        Task {
            await librarySetup.setupLibraries()
        }
    }
}
