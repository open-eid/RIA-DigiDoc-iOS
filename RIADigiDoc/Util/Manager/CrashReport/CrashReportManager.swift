// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import FirebaseCrashlytics
import UtilsLib

@MainActor
@Observable
final class CrashReportManager: CrashReportManagerProtocol, Loggable {

    private let dataStore: DataStoreProtocol
    private let crashReportClient: CrashReportClientProtocol

    var showCrashDialog = false

    init(
        dataStore: DataStoreProtocol,
        crashReportClient: CrashReportClientProtocol
    ) {
        self.dataStore = dataStore
        self.crashReportClient = crashReportClient
    }

    func evaluateCrashReporting() async {
        let isAlwaysEnabled = await dataStore.getIsCrashlyticsAlwaysEnabled()
        let hasUnsentReports = await crashReportClient.checkForUnsentReports()

        guard hasUnsentReports else {
            showCrashDialog = false
            return
        }

        if isAlwaysEnabled {
            handleUnsentReports(hasUnsentReports: true, send: true)
        } else {
            showCrashDialog = true
        }
    }

    func sendReport() async {
        CrashReportManager.logger().info("Sending crash report")
        handleUnsentReports(hasUnsentReports: true, send: true)
        showCrashDialog = false
    }

    func alwaysSendReport() async {
        CrashReportManager.logger().info("(Always) sending crash report")
        await dataStore.setIsCrashlyticsAlwaysEnabled(true)
        handleUnsentReports(hasUnsentReports: true, send: true)
        showCrashDialog = false
    }

    func doNotSendReport() async {
        CrashReportManager.logger().info("Not sending crash report")
        handleUnsentReports(hasUnsentReports: true, send: false)
        showCrashDialog = false
    }

    private func handleUnsentReports(hasUnsentReports: Bool, send: Bool) {
        CrashReportManager.logger().info("Has unsent crash reports: \(hasUnsentReports)")
        if send && hasUnsentReports {
            crashReportClient.sendUnsentReports()
        } else {
            crashReportClient.deleteUnsentReports()
        }
    }
}
