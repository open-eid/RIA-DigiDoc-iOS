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

import Foundation
import FirebaseCrashlytics
import UtilsLib

@MainActor
@Observable
final class CrashReportManager: CrashReportManagerProtocol, Loggable {

    private let dataStore: DataStoreProtocol

    var showCrashDialog = false

    init(
        dataStore: DataStoreProtocol
    ) {
        self.dataStore = dataStore
    }

    func evaluateCrashReporting() async {
        if await dataStore.getIsCrashlyticsAlwaysEnabled() {
            checkForUnsentReports(send: true)
        } else {
            showCrashDialog = true
        }
    }

    func sendReport() {
        CrashReportManager.logger().info("Sending crash report")
        checkForUnsentReports(send: true)
        showCrashDialog = false
    }

    func alwaysSendReport() async {
        CrashReportManager.logger().info("(Always) sending crash report")
        await dataStore.setIsCrashlyticsAlwaysEnabled(true)
        checkForUnsentReports(send: true)
        showCrashDialog = false
    }

    func doNotSendReport() {
        CrashReportManager.logger().info("Not sending crash report")
        checkForUnsentReports(send: false)
        showCrashDialog = false
    }

    private func checkForUnsentReports(send: Bool) {
        Crashlytics.crashlytics().checkForUnsentReports { hasUnsentReports in
            CrashReportManager.logger().info("Has unsent crash reports: \(hasUnsentReports)")
            if send && hasUnsentReports {
                Crashlytics.crashlytics().sendUnsentReports()
            } else {
                Crashlytics.crashlytics().deleteUnsentReports()
            }
        }
    }
}
