/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
import UtilsLib
import ConfigLib
import CommonsLib

@main
struct RIADigiDocApp: App {
    @State private var languageSettings: LanguageSettings
    @State private var themeSettings: ThemeSettings
    @State private var crashReportManager: CrashReportManager

    @State private var isSetupComplete = false
    @State private var isJailbroken: Bool = false
    @State private var isInitialLanguageSelected: Bool = false

    @State private var pathManager = NavigationPathManager()

    private let configurationProperty: ConfigurationProperty
    private let configurationLoader: ConfigurationLoaderProtocol
    private let dataStore: DataStoreProtocol
    private let fileManager: FileManagerProtocol
    private let fileUtil: FileUtilProtocol
    private let librarySetup: LibrarySetup
    private let documentsMigrator: DocumentsMigratorProtocol

    init() {
        _languageSettings = State(wrappedValue: Container.shared.languageSettings())
        _themeSettings = State(wrappedValue: Container.shared.themeSettings())
        _crashReportManager = State(wrappedValue: Container.shared.crashReportManager())

        self.configurationProperty = Container.shared.configurationProperty()
        self.configurationLoader = Container.shared.configurationLoader()
        self.dataStore = Container.shared.dataStore()
        self.fileManager = Container.shared.fileManager()
        self.fileUtil = Container.shared.fileUtil()
        self.librarySetup = Container.shared.librarySetup()
        self.documentsMigrator = Container.shared.documentsMigrator()
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
            await crashReportManager.evaluateCrashReporting()
            fileUtil.removeSavedFilesDirectory(savedFilesDirectory: nil)

            let isRecentDocumentsMigrationDone = await dataStore.getIsRecentDocumentsMigrationDone()
            if !isRecentDocumentsMigrationDone {
                try await documentsMigrator.migrateRecentDocuments()
                await dataStore.setIsRecentDocumentsMigrationDone(true)
            }

            await languageSettings.loadSelectedLanguage()
            isInitialLanguageSelected = await dataStore.getIsInitialLanguageSelected()
            await MainActor.run {
                self.isSetupComplete = true
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            let currentTheme = themeSettings.getSelectedTheme()

            Group {
                if isJailbroken {
                    JailbreakView()
                        .environment(\.typography, Typography.current())
                        .environment(themeSettings)
                        .preferredColorScheme(currentTheme.colorScheme)
                } else if isSetupComplete {
                    NavigationStack(path: $pathManager.path) {
                        if isInitialLanguageSelected {
                            ContentView()
                                .environment(pathManager)
                                .appNavigation(pathManager: pathManager)
                                .alert(
                                    languageSettings.localized("Crash report title"),
                                    isPresented: $crashReportManager.showCrashDialog
                                ) {
                                    Button(languageSettings.localized("Crash report send")) {
                                        Task {
                                            await crashReportManager.sendReport()
                                        }
                                    }
                                    Button(languageSettings.localized("Crash report always send")) {
                                        Task {
                                            await crashReportManager.alwaysSendReport()
                                        }
                                    }
                                    Button(languageSettings.localized("Crash report dont send"), role: .cancel) {
                                        Task {
                                            await crashReportManager.doNotSendReport()
                                        }
                                    }
                                } message: {
                                    Text(verbatim: languageSettings.localized("Crash report message"))
                                }
                        } else {
                            InitView()
                                .environment(pathManager)
                                .appNavigation(pathManager: pathManager)
                        }
                    }
                    .environment(\.typography, Typography.current())
                    .environment(languageSettings)
                    .environment(themeSettings)
                    .overlay(
                        alignment: .center,
                        content: {
                            ToastOverlay()
                                .environment(themeSettings)
                        }
                    )
                    .preferredColorScheme(currentTheme.colorScheme)
                } else {
                    LaunchScreenView()
                        .onAppear { onLaunchScreenViewAppear() }
                        .environment(themeSettings)
                        .preferredColorScheme(.light)
                        .environment(languageSettings)
                }
            }
            .hideSensitiveContent()
        }
    }
}
