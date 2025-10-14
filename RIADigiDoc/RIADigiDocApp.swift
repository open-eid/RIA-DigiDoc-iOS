import SwiftUI
import FactoryKit
import LibdigidocLibSwift
import UtilsLib
import ConfigLib
import CommonsLib

@main
struct RIADigiDocApp: App {
    @StateObject private var languageSettings: LanguageSettings
    @StateObject private var themeSettings: ThemeSettings

    @State private var isSetupComplete = false
    @State private var isJailbroken: Bool = false

    private let configurationProperty: ConfigurationProperty
    private let configurationLoader: ConfigurationLoaderProtocol
    private let fileManager: FileManagerProtocol
    private let librarySetup: LibrarySetup

    init() {
        _languageSettings = StateObject(wrappedValue: Container.shared.languageSettings())
        _themeSettings = StateObject(wrappedValue: Container.shared.themeSettings())

        self.configurationProperty = Container.shared.configurationProperty()
        self.configurationLoader = Container.shared.configurationLoader()
        self.fileManager = Container.shared.fileManager()
        self.librarySetup = Container.shared.librarySetup()
    }

    private func onLaunchScreenViewAppear() {
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

    var body: some Scene {
        WindowGroup {
            let currentTheme = themeSettings.getSelectedTheme()

            if isJailbroken {
                JailbreakView()
                    .environment(\.typography, Typography.current())
                    .environmentObject(themeSettings)
                    .preferredColorScheme(currentTheme.colorScheme)
            } else if isSetupComplete {
                NavigationView {
                    ContentView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environment(\.typography, Typography.current())
                .environmentObject(languageSettings)
                .environmentObject(themeSettings)
                .overlay(
                    ToastOverlay()
                        .environmentObject(themeSettings)
                )
                .preferredColorScheme(currentTheme.colorScheme)
            } else {
                LaunchScreenView()
                    .onAppear { onLaunchScreenViewAppear() }
                    .environmentObject(themeSettings)
            }
        }
    }
}
