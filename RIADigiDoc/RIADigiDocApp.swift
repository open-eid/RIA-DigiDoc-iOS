/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
    private let fileUtil: FileUtilProtocol
    private let librarySetup: LibrarySetup

    init() {
        _languageSettings = StateObject(wrappedValue: Container.shared.languageSettings())
        _themeSettings = StateObject(wrappedValue: Container.shared.themeSettings())

        self.configurationProperty = Container.shared.configurationProperty()
        self.configurationLoader = Container.shared.configurationLoader()
        self.fileManager = Container.shared.fileManager()
        self.fileUtil = Container.shared.fileUtil()
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
            fileUtil.removeSavedFilesDirectory(savedFilesDirectory: nil)
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
                    .preferredColorScheme(.light)
            }
        }
    }
}
