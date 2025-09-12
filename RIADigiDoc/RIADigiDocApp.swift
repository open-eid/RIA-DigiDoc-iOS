import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import UtilsLib
import ConfigLib
import CommonsLib

@main
struct RIADigiDocApp: App {
    @AppStorage(Theme.key) private var colorSchemeRawValue: Int = Theme.system.rawValue
    var currentTheme: Theme {
        Theme(rawValue: colorSchemeRawValue) ?? .system
    }

    @StateObject private var languageSettings: LanguageSettings
    @State private var isSetupComplete = false
    @State private var isJailbroken: Bool = false

    private let configurationProperty: ConfigurationProperty
    private let configurationLoader: ConfigurationLoaderProtocol
    private let fileManager: FileManagerProtocol
    private let librarySetup: LibrarySetup

    init() {
        _languageSettings = StateObject(wrappedValue: Container.shared.languageSettings())
        self.configurationProperty = Container.shared.configurationProperty()
        self.configurationLoader = Container.shared.configurationLoader()
        self.fileManager = Container.shared.fileManager()
        self.librarySetup = Container.shared.librarySetup()
    }

    var body: some Scene {
        WindowGroup {
            if isJailbroken {
                JailbreakView()
                    .environment(\.typography, Typography.current())
                    .preferredColorScheme(currentTheme.colorScheme)
            } else if isSetupComplete {
                NavigationView {
                    ContentView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(languageSettings)
                .environment(\.typography, Typography.current())
                .overlay(ToastOverlay())
                .preferredColorScheme(currentTheme.colorScheme)
            } else {
                LaunchScreenView()
                    .onAppear {
                        Task {
                            if await JailbreakDetection.isDeviceJailbroken(fileManager: fileManager) {
                                await MainActor.run {
                                    self.isJailbroken = true
                                }
                                return
                            }

                            await librarySetup.setupLibraries()
                            await MainActor.run {
                                self.isSetupComplete = true
                            }
                        }
                    }
                    .preferredColorScheme(currentTheme.colorScheme)
            }
        }
    }
}
